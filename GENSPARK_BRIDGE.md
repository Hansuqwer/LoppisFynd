# Genspark AI Chat ↔ Claude Code Bridge

Bidirectional integration between Genspark AI Chat and Claude Code for unlimited exploration with local file context.

## Components

### 1. MCP Server (`genspark-mcp-server/`)
TypeScript MCP server that:
- Authenticates with Genspark AI Chat API
- Sends queries with file context
- Maintains conversation history
- Stores conversations in `~/.claude/genspark-history/`

**Installation:**
```bash
cd genspark-mcp-server
npm install
npm run build
```

### 2. Claude Code Skills

#### `/genspark` - Send queries to Genspark
```bash
# Basic query
/genspark "Explain the architecture"

# With file context
/genspark "Review for security" lib/services/sync/

# Continue conversation
/genspark --continue conv_123 "What about error handling?"

# Export full project
/genspark --export
```

#### `/import-genspark` - Import responses
```bash
# Import and apply changes
/import-genspark .sisyphus/genspark-responses/response.md

# Preview only
/import-genspark --dry-run response.md
```

### 3. Export Script (`scripts/export-context-to-genspark.sh`)
Bundles project context for Genspark:
```bash
# Export to file
./scripts/export-context-to-genspark.sh

# Export to clipboard
./scripts/export-context-to-genspark.sh --clipboard
```

## Setup

### 1. Install MCP Server
```bash
cd genspark-mcp-server
npm install
npm run build
```

### 2. Configure Claude Code
Add to `.claude/settings.json`:
```json
{
  "mcpServers": {
    "genspark": {
      "command": "node",
      "args": ["/Users/hansvilund/HansuQWER/WorkSpace/LoppisFynd/LoppisFynd-main/genspark-mcp-server/build/index.js"],
      "env": {
        "GENSPARK_API_KEY": "${GENSPARK_API_KEY}"
      }
    }
  }
}
```

### 3. Set API Key
```bash
export GENSPARK_API_KEY="your-api-key-here"
```

### 4. Create Response Directory
```bash
mkdir -p .sisyphus/genspark-responses
```

## Workflow

### Exploration Phase
1. **Export Context**: `/genspark --export` or `./scripts/export-context-to-genspark.sh`
2. **Ask Questions**: Use Genspark web UI for unlimited queries
3. **Save Responses**: Copy to `.sisyphus/genspark-responses/`

### Implementation Phase
1. **Import Response**: `/import-genspark response.md`
2. **Review Changes**: Check applied edits
3. **Verify**: Run tests and analysis
4. **Iterate**: Use Claude Code for refinement (benefits from prompt cache)

## Benefits

- **Unlimited Exploration**: No token limits in Genspark
- **Local Context**: Send file contents for accurate analysis
- **Prompt Cache Preservation**: Keep Claude Code cache warm for implementation
- **Conversation History**: Persist and continue discussions
- **Automated Import**: Apply code suggestions with verification

## Architecture

```
┌─────────────────┐
│  Claude Code    │
│                 │
│  /genspark ────┼──┐
│  /import-genspark│  │
└─────────────────┘  │
                     │
                     ▼
            ┌────────────────┐
            │  MCP Server    │
            │  (Node.js)     │
            └────────┬───────┘
                     │
                     ▼
            ┌────────────────┐
            │ Genspark API   │
            │ (REST/WebSocket)│
            └────────────────┘
                     │
                     ▼
            ┌────────────────┐
            │ Conversation   │
            │ History Store  │
            │ (~/.claude/)   │
            └────────────────┘
```

## Security

- API keys stored in environment variables
- Sensitive paths excluded from export (see CLAUDE.md)
- No secrets, tokens, or credentials sent to Genspark
- Conversation history stored locally

## Troubleshooting

### MCP Server Not Found
```bash
# Check path in .claude/settings.json
ls -la genspark-mcp-server/build/index.js

# Rebuild if needed
cd genspark-mcp-server && npm run build
```

### API Key Error
```bash
# Verify key is set
echo $GENSPARK_API_KEY

# Add to shell profile
echo 'export GENSPARK_API_KEY="your-key"' >> ~/.zshrc
source ~/.zshrc
```

### Import Parse Error
Ensure Genspark responses follow this format:
```markdown
### path/to/file.dart

\`\`\`dart
// code here
\`\`\`
```

## Future Enhancements

- [ ] Streaming responses in Claude Code
- [ ] Conversation branching
- [ ] Response caching
- [ ] Web UI for conversation management
- [ ] Cost tracking and analytics
- [ ] Webhook support for async responses

## Contributing

See individual component READMEs:
- `genspark-mcp-server/README.md` - MCP server details
- `.claude/skills/genspark.md` - Skill usage
- `.claude/skills/import-genspark.md` - Import skill usage
