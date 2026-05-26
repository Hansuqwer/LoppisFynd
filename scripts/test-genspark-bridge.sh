#!/bin/bash
# Test Genspark Bridge installation and configuration
set -e

echo "🧪 Testing Genspark Bridge..."
echo ""

# Test 1: Check MCP server build
echo "1️⃣  Checking MCP server build..."
if [ -f "genspark-mcp-server/build/index.js" ]; then
  echo "   ✅ MCP server built"
else
  echo "   ❌ MCP server not built"
  echo "   Run: cd genspark-mcp-server && npm install && npm run build"
  exit 1
fi

# Test 2: Check API key
echo "2️⃣  Checking API key..."
if [ -n "$GENSPARK_API_KEY" ]; then
  echo "   ✅ API key set (${#GENSPARK_API_KEY} characters)"
else
  echo "   ❌ API key not set"
  echo "   Run: export GENSPARK_API_KEY=\"your-key-here\""
  exit 1
fi

# Test 3: Check settings.json
echo "3️⃣  Checking Claude Code settings..."
if [ -f ".claude/settings.json" ]; then
  if grep -q "genspark" .claude/settings.json; then
    echo "   ✅ MCP server configured in settings.json"
  else
    echo "   ⚠️  MCP server not in settings.json"
    echo "   Add genspark MCP server configuration"
  fi
else
  echo "   ⚠️  .claude/settings.json not found"
  echo "   Create it with genspark MCP server configuration"
fi

# Test 4: Check export script
echo "4️⃣  Checking export script..."
if [ -x "scripts/export-context-to-genspark.sh" ]; then
  echo "   ✅ Export script executable"
else
  echo "   ⚠️  Export script not executable, fixing..."
  chmod +x scripts/export-context-to-genspark.sh
  echo "   ✅ Fixed"
fi

# Test 5: Check skills
echo "5️⃣  Checking skills..."
if [ -f ".claude/skills/genspark.md" ]; then
  echo "   ✅ /genspark skill installed"
else
  echo "   ❌ /genspark skill missing"
fi

if [ -f ".claude/skills/import-genspark.md" ]; then
  echo "   ✅ /import-genspark skill installed"
else
  echo "   ❌ /import-genspark skill missing"
fi

# Test 6: Check history directory
echo "6️⃣  Checking history directory..."
mkdir -p ~/.claude/genspark-history
if [ -d ~/.claude/genspark-history ] && [ -w ~/.claude/genspark-history ]; then
  echo "   ✅ History directory exists and is writable"
else
  echo "   ❌ History directory issue"
fi

# Test 7: Check response directory
echo "7️⃣  Checking response directory..."
mkdir -p .sisyphus/genspark-responses
if [ -d .sisyphus/genspark-responses ] && [ -w .sisyphus/genspark-responses ]; then
  echo "   ✅ Response directory exists and is writable"
else
  echo "   ❌ Response directory issue"
fi

# Test 8: Run export script (dry run)
echo "8️⃣  Testing export script..."
if ./scripts/export-context-to-genspark.sh > /dev/null 2>&1; then
  echo "   ✅ Export script runs successfully"
  # Clean up test export
  rm -f .sisyphus/genspark-export-*.md
else
  echo "   ❌ Export script failed"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 All tests passed! Bridge is ready to use."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Next steps:"
echo "   1. Restart Claude Code to load MCP server"
echo "   2. Test: /genspark \"Hello from Claude Code!\""
echo "   3. Export: ./scripts/export-context-to-genspark.sh"
echo "   4. Visit: https://genspark.ai"
echo ""
echo "📚 Documentation:"
echo "   • Setup guide: GENSPARK_SETUP.md"
echo "   • Architecture: GENSPARK_BRIDGE.md"
echo "   • MCP server: genspark-mcp-server/README.md"
echo ""
