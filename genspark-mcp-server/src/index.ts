#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
} from "@modelcontextprotocol/sdk/types.js";
import fetch from "node-fetch";
import * as fs from "fs/promises";
import * as path from "path";
import * as os from "os";

// Genspark API configuration
const GENSPARK_API_BASE = process.env.GENSPARK_API_BASE || "https://api.genspark.ai/v1";
const GENSPARK_API_KEY = process.env.GENSPARK_API_KEY;

// Conversation history storage
const HISTORY_DIR = path.join(os.homedir(), ".claude", "genspark-history");

interface GensparkMessage {
  role: "user" | "assistant";
  content: string;
  timestamp: string;
}

interface GensparkConversation {
  id: string;
  messages: GensparkMessage[];
  createdAt: string;
  updatedAt: string;
}

// Ensure history directory exists
async function ensureHistoryDir(): Promise<void> {
  try {
    await fs.mkdir(HISTORY_DIR, { recursive: true });
  } catch (error) {
    console.error("Failed to create history directory:", error);
  }
}

// Load conversation history
async function loadConversation(conversationId: string): Promise<GensparkConversation | null> {
  try {
    const filePath = path.join(HISTORY_DIR, `${conversationId}.json`);
    const data = await fs.readFile(filePath, "utf-8");
    return JSON.parse(data);
  } catch {
    return null;
  }
}

// Save conversation history
async function saveConversation(conversation: GensparkConversation): Promise<void> {
  try {
    const filePath = path.join(HISTORY_DIR, `${conversation.id}.json`);
    await fs.writeFile(filePath, JSON.stringify(conversation, null, 2));
  } catch (error) {
    console.error("Failed to save conversation:", error);
  }
}

// List all conversations
async function listConversations(): Promise<string[]> {
  try {
    const files = await fs.readdir(HISTORY_DIR);
    return files
      .filter((f) => f.endsWith(".json"))
      .map((f) => f.replace(".json", ""));
  } catch {
    return [];
  }
}

// Call Genspark API
async function callGensparkAPI(
  query: string,
  context?: Record<string, string>,
  conversationId?: string
): Promise<{ response: string; conversationId: string }> {
  if (!GENSPARK_API_KEY) {
    throw new Error("GENSPARK_API_KEY environment variable not set");
  }

  // Load or create conversation
  let conversation: GensparkConversation;
  if (conversationId) {
    const existing = await loadConversation(conversationId);
    if (existing) {
      conversation = existing;
    } else {
      conversation = {
        id: conversationId,
        messages: [],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
    }
  } else {
    conversation = {
      id: `conv_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      messages: [],
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
  }

  // Build message with context
  let fullMessage = query;
  if (context && Object.keys(context).length > 0) {
    fullMessage += "\n\n## Context Files\n\n";
    for (const [filePath, content] of Object.entries(context)) {
      fullMessage += `### ${filePath}\n\`\`\`\n${content}\n\`\`\`\n\n`;
    }
  }

  // Add user message to history
  conversation.messages.push({
    role: "user",
    content: fullMessage,
    timestamp: new Date().toISOString(),
  });

  try {
    // Call Genspark API
    const response = await fetch(`${GENSPARK_API_BASE}/chat`, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${GENSPARK_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: fullMessage,
        conversationId: conversation.id,
        history: conversation.messages.slice(0, -1), // Exclude current message
      }),
    });

    if (!response.ok) {
      throw new Error(`Genspark API error: ${response.status} ${response.statusText}`);
    }

    const data = await response.json() as { response: string };
    const assistantMessage = data.response;

    // Add assistant response to history
    conversation.messages.push({
      role: "assistant",
      content: assistantMessage,
      timestamp: new Date().toISOString(),
    });

    conversation.updatedAt = new Date().toISOString();
    await saveConversation(conversation);

    return {
      response: assistantMessage,
      conversationId: conversation.id,
    };
  } catch (error) {
    console.error("Genspark API call failed:", error);
    throw error;
  }
}

// Define MCP tools
const tools: Tool[] = [
  {
    name: "send_to_genspark",
    description:
      "Send a query to Genspark AI Chat with optional file context. Returns the response and conversation ID for follow-up queries.",
    inputSchema: {
      type: "object",
      properties: {
        query: {
          type: "string",
          description: "The question or prompt to send to Genspark",
        },
        files: {
          type: "object",
          description:
            "Optional map of file paths to their contents (e.g., {'lib/main.dart': 'content...'})",
          additionalProperties: {
            type: "string",
          },
        },
        conversationId: {
          type: "string",
          description: "Optional conversation ID to continue an existing conversation",
        },
      },
      required: ["query"],
    },
  },
  {
    name: "list_genspark_conversations",
    description: "List all saved Genspark conversation IDs",
    inputSchema: {
      type: "object",
      properties: {},
    },
  },
  {
    name: "get_genspark_conversation",
    description: "Retrieve the full history of a Genspark conversation",
    inputSchema: {
      type: "object",
      properties: {
        conversationId: {
          type: "string",
          description: "The conversation ID to retrieve",
        },
      },
      required: ["conversationId"],
    },
  },
];

// Create MCP server
const server = new Server(
  {
    name: "genspark",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Handle tool list requests
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return { tools };
});

// Handle tool call requests
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    if (name === "send_to_genspark") {
      const { query, files, conversationId } = args as {
        query: string;
        files?: Record<string, string>;
        conversationId?: string;
      };

      const result = await callGensparkAPI(query, files, conversationId);

      return {
        content: [
          {
            type: "text",
            text: `**Conversation ID:** ${result.conversationId}\n\n${result.response}`,
          },
        ],
      };
    } else if (name === "list_genspark_conversations") {
      const conversations = await listConversations();
      return {
        content: [
          {
            type: "text",
            text: conversations.length > 0
              ? `Found ${conversations.length} conversations:\n${conversations.join("\n")}`
              : "No conversations found",
          },
        ],
      };
    } else if (name === "get_genspark_conversation") {
      const { conversationId } = args as { conversationId: string };
      const conversation = await loadConversation(conversationId);

      if (!conversation) {
        return {
          content: [
            {
              type: "text",
              text: `Conversation ${conversationId} not found`,
            },
          ],
        };
      }

      const formatted = conversation.messages
        .map((msg) => `**${msg.role}** (${msg.timestamp}):\n${msg.content}\n`)
        .join("\n---\n\n");

      return {
        content: [
          {
            type: "text",
            text: `# Conversation: ${conversationId}\n\nCreated: ${conversation.createdAt}\nUpdated: ${conversation.updatedAt}\n\n${formatted}`,
          },
        ],
      };
    }

    throw new Error(`Unknown tool: ${name}`);
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    return {
      content: [
        {
          type: "text",
          text: `Error: ${errorMessage}`,
        },
      ],
      isError: true,
    };
  }
});

// Start server
async function main() {
  await ensureHistoryDir();
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Genspark MCP server running on stdio");
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
