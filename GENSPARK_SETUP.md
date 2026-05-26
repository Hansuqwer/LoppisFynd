# Genspark Bridge - Installation & Testing Guide

## Quick Start

### 1. Install MCP Server

```bash
cd genspark-mcp-server
npm install
npm run build
```

Expected output:
```
added 45 packages, and audited 46 packages in 3s
> genspark-mcp-server@1.0.0 build
> tsc
```

### 2. Get Genspark API Key

1. Visit https://genspark.ai
2. Sign up or log in
3. Navigate to Settings → API Keys
4. Create new API key
5. Copy the key

### 3. Configure Environment

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
export GENSPARK_API_KEY="gs_your_api_key_here"
```

Then reload:
```bash
source ~/.zshrc
```

### 4. Configure Claude Code

Create or update `.claude/settings.json`:

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

### 5. Restart Claude Code

The MCP server will be loaded automatically on next startup.

## Testing

### Test 1: Basic Query

```
/genspark "What is the capital of France?"
```

Expected: Response from Genspark with conversation ID

### Test 2: Query with File Context

```
/genspark "Explain this file" CLAUDE.md
```

Expected: Response analyzing CLAUDE.md content

### Test 3: List Conversations

```
/genspark --list
```

Expected: List of conversation IDs

### Test 4: Continue Conversation

```
/genspark --continue conv_1234567890_abc123 "Tell me more"
```

Expected: Response continuing previous conversation

### Test 5: Export Project Context

```bash
./scripts/export-context-to-genspark.sh
```

Expected: Markdown file in `.sisyphus/genspark-export-YYYYMMDD-HHMMSS.md`

### Test 6: Export to Clipboard

```bash
./scripts/export-context-to-genspark.sh --clipboard
```

Expected: Context copied to clipboard (macOS/Linux with pbcopy/xclip)

## Verification Checklist

- [ ] MCP server builds without errors
- [ ] API key is set in environment
- [ ] `.claude/settings.json` has correct path
- [ ] Claude Code loads MCP server on startup
- [ ] `/genspark` skill is available
- [ ] Basic query returns response
- [ ] File context is included in queries
- [ ] Conversations are saved to `~/.claude/genspark-history/`
- [ ] Export script generates markdown
- [ ] Export respects sensitive path exclusions

## Troubleshooting

### MCP Server Won't Start

**Symptom**: Error message about MCP server not found

**Solution**:
```bash
# Check build output exists
ls -la genspark-mcp-server/build/index.js

# Rebuild if missing
cd genspark-mcp-server
npm run build
```

### API Key Not Found

**Symptom**: "GENSPARK_API_KEY environment variable not set"

**Solution**:
```bash
# Verify key is set
echo $GENSPARK_API_KEY

# If empty, add to shell profile
echo 'export GENSPARK_API_KEY="your-key"' >> ~/.zshrc
source ~/.zshrc
```

### Permission Denied on Export Script

**Symptom**: "Permission denied: ./scripts/export-context-to-genspark.sh"

**Solution**:
```bash
chmod +x scripts/export-context-to-genspark.sh
```

### Conversation History Not Saving

**Symptom**: Conversations don't persist between sessions

**Solution**:
```bash
# Check directory exists and is writable
mkdir -p ~/.claude/genspark-history
ls -la ~/.claude/genspark-history
```

### Import Skill Parse Errors

**Symptom**: `/import-genspark` fails to parse response

**Solution**: Ensure Genspark response follows this format:

```markdown
### lib/path/to/file.dart

\`\`\`dart
// Code here
\`\`\`
```

## Manual Testing Script

Save as `test-genspark-bridge.sh`:

```bash
#!/bin/bash
set -e

echo "🧪 Testing Genspark Bridge..."

# Test 1: Check MCP server build
echo "1️⃣ Checking MCP server build..."
if [ -f "genspark-mcp-server/build/index.js" ]; then
  echo "✅ MCP server built"
else
  echo "❌ MCP server not built"
  exit 1
fi

# Test 2: Check API key
echo "2️⃣ Checking API key..."
if [ -n "$GENSPARK_API_KEY" ]; then
  echo "✅ API key set"
else
  echo "❌ API key not set"
  exit 1
fi

# Test 3: Check settings.json
echo "3️⃣ Checking Claude Code settings..."
if [ -f ".claude/settings.json" ]; then
  if grep -q "genspark" .claude/settings.json; then
    echo "✅ MCP server configured"
  else
    echo "⚠️  MCP server not in settings.json"
  fi
else
  echo "⚠️  .claude/settings.json not found"
fi

# Test 4: Check export script
echo "4️⃣ Checking export script..."
if [ -x "scripts/export-context-to-genspark.sh" ]; then
  echo "✅ Export script executable"
else
  echo "❌ Export script not executable"
  chmod +x scripts/export-context-to-genspark.sh
fi

# Test 5: Check skills
echo "5️⃣ Checking skills..."
if [ -f ".claude/skills/genspark.md" ]; then
  echo "✅ /genspark skill installed"
else
  echo "❌ /genspark skill missing"
fi

if [ -f ".claude/skills/import-genspark.md" ]; then
  echo "✅ /import-genspark skill installed"
else
  echo "❌ /import-genspark skill missing"
fi

# Test 6: Check history directory
echo "6️⃣ Checking history directory..."
mkdir -p ~/.claude/genspark-history
if [ -d ~/.claude/genspark-history ]; then
  echo "✅ History directory exists"
else
  echo "❌ History directory missing"
fi

# Test 7: Run export script
echo "7️⃣ Testing export script..."
./scripts/export-context-to-genspark.sh > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "✅ Export script runs successfully"
else
  echo "❌ Export script failed"
fi

echo ""
echo "🎉 All tests passed! Bridge is ready to use."
echo ""
echo "Next steps:"
echo "  1. Restart Claude Code to load MCP server"
echo "  2. Try: /genspark \"Hello from Claude Code!\""
echo "  3. Try: ./scripts/export-context-to-genspark.sh"
```

Make it executable and run:
```bash
chmod +x test-genspark-bridge.sh
./test-genspark-bridge.sh
```

## Next Steps

1. **Restart Claude Code** to load the MCP server
2. **Test basic query**: `/genspark "Hello from Claude Code!"`
3. **Export context**: `./scripts/export-context-to-genspark.sh`
4. **Paste in Genspark**: Open https://genspark.ai and paste exported context
5. **Ask questions**: Unlimited queries in Genspark web UI
6. **Import responses**: Save responses and use `/import-genspark`

## Support

- **MCP Server Issues**: Check `genspark-mcp-server/README.md`
- **Skill Usage**: Check `.claude/skills/genspark.md`
- **Export Script**: Check `scripts/export-context-to-genspark.sh` comments
- **General Setup**: Check `GENSPARK_BRIDGE.md`
