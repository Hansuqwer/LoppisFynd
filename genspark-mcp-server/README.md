# Genspark MCP Server

MCP (Model Context Protocol) server for integrating Genspark AI Chat with Claude Code.

## Features

- Send queries to Genspark with file context
- Maintain conversation history across sessions
- Continue previous conversations
- List and retrieve conversation history

## Installation

```bash
cd genspark-mcp-server
npm install
npm run build
```

## Configuration

Add to your Claude Code settings (`.claude/settings.json`):

```json
{
  "mcpServers": {
    "genspark": {
      "command": "node",
      "args": ["/Users/hansvilund/HansuQWER/WorkSpace/LoppisFynd/LoppisFynd-main/genspark-mcp-server/build/index.js"],
      "env": {
        "GENSPARK_API_KEY": "${GENSPARK_API_KEY}",
        "GENSPARK_API_BASE": "https://api.genspark.ai/v1"
      }
    }
  }
}
```

Set your API key in your shell environment:

```bash
export GENSPARK_API_KEY="your-api-key-here"
```

## Usage

The server provides three MCP tools:

### 1. send_to_genspark

Send a query to Genspark with optional file context.

```typescript
{
  query: "Explain this code",
  files: {
    "lib/main.dart": "content...",
    "lib/app.dart": "content..."
  },
  conversationId: "conv_123" // optional, to continue conversation
}
```

### 2. list_genspark_conversations

List all saved conversation IDs.

### 3. get_genspark_conversation

Retrieve full conversation history by ID.

```typescript
{
  conversationId: "conv_123"
}
```

## Conversation Storage

Conversations are stored in `~/.claude/genspark-history/` as JSON files.

## API Compatibility

This server is designed to work with the Genspark AI Chat API. If the API structure differs from the implementation, you may need to adjust the `callGensparkAPI` function in `src/index.ts`.

## Development

```bash
# Watch mode for development
npm run watch

# Build for production
npm run build
```

## Troubleshooting

- **API Key not set**: Ensure `GENSPARK_API_KEY` is set in your environment
- **Connection errors**: Check `GENSPARK_API_BASE` URL is correct
- **Permission errors**: Ensure `~/.claude/genspark-history/` is writable
