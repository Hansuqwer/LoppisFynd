#!/bin/bash
# Export project context to Genspark AI Chat
# Usage: ./scripts/export-context-to-genspark.sh [--clipboard|--file output.md]

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_MODE="${1:-file}"
OUTPUT_FILE="${2:-$PROJECT_ROOT/.sisyphus/genspark-export-$(date +%Y%m%d-%H%M%S).md}"

# Sensitive paths to exclude (from CLAUDE.md)
EXCLUDE_PATTERNS=(
  "**/.env"
  "**/.env.*"
  "**/secrets/**"
  "**/*.p8"
  "**/*.mobileprovision"
  "android/key.properties"
  "android/keystore/**"
  "ios/Runner/GoogleService-Info-Prod.plist"
  "android/app/google-services-prod.json"
  "roadmapv2/**"
  "**/*.g.dart"
  "**/*.freezed.dart"
  "build/**"
  ".dart_tool/**"
  "node_modules/**"
  ".git/**"
)

# Build find exclude arguments
FIND_EXCLUDES=""
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
  FIND_EXCLUDES="$FIND_EXCLUDES -not -path '*/${pattern#**/}'"
done

echo "🚀 Exporting Bokfynd project context to Genspark AI Chat..."

# Create output directory
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Start building the export
cat > "$OUTPUT_FILE" <<'EOF'
# Bokfynd Project Context Export

**Generated:** $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Project:** Bokfynd (formerly LoppisFynd)
**Purpose:** Swedish book reseller mobile app (iOS + Android)

---

## Quick Reference

- **Language:** Dart/Flutter
- **State Management:** Riverpod
- **Database:** Drift (SQLite)
- **Backend:** Supabase
- **Architecture:** Offline-first, feature-based

---

EOF

# Add project instructions
echo "## Project Instructions (CLAUDE.md)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
if [ -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  echo '```markdown' >> "$OUTPUT_FILE"
  cat "$PROJECT_ROOT/CLAUDE.md" >> "$OUTPUT_FILE"
  echo '```' >> "$OUTPUT_FILE"
else
  echo "*CLAUDE.md not found*" >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# Add .claude/CLAUDE.md if exists
if [ -f "$PROJECT_ROOT/.claude/CLAUDE.md" ]; then
  echo "## Project Memory (.claude/CLAUDE.md)" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo '```markdown' >> "$OUTPUT_FILE"
  cat "$PROJECT_ROOT/.claude/CLAUDE.md" >> "$OUTPUT_FILE"
  echo '```' >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Add project structure
echo "## Project Structure" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo '```' >> "$OUTPUT_FILE"
cd "$PROJECT_ROOT"
tree -L 3 -I 'build|.dart_tool|node_modules|.git|roadmapv2' --dirsfirst >> "$OUTPUT_FILE" 2>/dev/null || {
  # Fallback if tree is not installed
  find . -maxdepth 3 -type d \
    -not -path '*/build/*' \
    -not -path '*/.dart_tool/*' \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    -not -path '*/roadmapv2/*' \
    | sort >> "$OUTPUT_FILE"
}
echo '```' >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Add key configuration files
echo "## Key Configuration Files" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

KEY_FILES=(
  "pubspec.yaml"
  "analysis_options.yaml"
  "l10n.yaml"
  "lib/core/database/app_database.dart"
  "lib/core/app/providers.dart"
)

for file in "${KEY_FILES[@]}"; do
  if [ -f "$PROJECT_ROOT/$file" ]; then
    echo "### $file" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    head -n 100 "$PROJECT_ROOT/$file" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  fi
done

# Add architecture documentation
echo "## Architecture Documentation" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

ARCH_DOCS=(
  "docs/bokfynd/STRATEGY.md"
  "docs/bokfynd/ARCHITECTURE.md"
  "docs/migration/MIGRATION_PLAN.md"
  "ARCHITECTURE_REVIEW.md"
)

for doc in "${ARCH_DOCS[@]}"; do
  if [ -f "$PROJECT_ROOT/$doc" ]; then
    echo "### $doc" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo '```markdown' >> "$OUTPUT_FILE"
    cat "$PROJECT_ROOT/$doc" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  fi
done

# Add feature overview
echo "## Feature Modules" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ -d "$PROJECT_ROOT/lib/features" ]; then
  for feature in "$PROJECT_ROOT/lib/features"/*; do
    if [ -d "$feature" ]; then
      feature_name=$(basename "$feature")
      echo "### $feature_name" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"

      # List main files
      echo "**Files:**" >> "$OUTPUT_FILE"
      find "$feature" -maxdepth 2 -name "*.dart" -not -name "*.g.dart" -not -name "*.freezed.dart" | sort | while read -r file; do
        echo "- $(basename "$file")" >> "$OUTPUT_FILE"
      done
      echo "" >> "$OUTPUT_FILE"
    fi
  done
fi

# Add service overview
echo "## Services" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ -d "$PROJECT_ROOT/lib/services" ]; then
  for service in "$PROJECT_ROOT/lib/services"/*; do
    if [ -d "$service" ]; then
      service_name=$(basename "$service")
      echo "### $service_name" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"

      # List main files
      echo "**Files:**" >> "$OUTPUT_FILE"
      find "$service" -maxdepth 2 -name "*.dart" -not -name "*.g.dart" -not -name "*.freezed.dart" | sort | while read -r file; do
        echo "- $(basename "$file")" >> "$OUTPUT_FILE"
      done
      echo "" >> "$OUTPUT_FILE"
    fi
  done
fi

# Add database schema summary
echo "## Database Schema (Drift)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

if [ -d "$PROJECT_ROOT/lib/core/database/tables" ]; then
  echo "**Tables:**" >> "$OUTPUT_FILE"
  find "$PROJECT_ROOT/lib/core/database/tables" -name "*.dart" | sort | while read -r table; do
    table_name=$(basename "$table" .dart)
    echo "- $table_name" >> "$OUTPUT_FILE"
  done
  echo "" >> "$OUTPUT_FILE"
fi

# Add recent git history (if in git repo)
if [ -d "$PROJECT_ROOT/.git" ]; then
  echo "## Recent Changes (Last 10 Commits)" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo '```' >> "$OUTPUT_FILE"
  git -C "$PROJECT_ROOT" log --oneline -10 >> "$OUTPUT_FILE" 2>/dev/null || echo "Git history unavailable" >> "$OUTPUT_FILE"
  echo '```' >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Add footer
cat >> "$OUTPUT_FILE" <<'EOF'

---

## How to Use This Export

1. **Copy to Genspark**: Paste this entire document into Genspark AI Chat
2. **Ask Questions**: Query architecture, security, performance, migration strategy
3. **Unlimited Exploration**: No token limits - ask as many follow-up questions as needed
4. **Bring Back Insights**: Copy responses to `.sisyphus/genspark-responses/` for import

## Suggested Questions

- "What are the main architectural risks in this codebase?"
- "How should we approach the Bokfynd migration?"
- "Identify security vulnerabilities in the sync service"
- "What performance optimizations would have the biggest impact?"
- "Review the database schema for normalization issues"
- "Suggest improvements to the offline-first architecture"

EOF

# Output handling
if [ "$OUTPUT_MODE" = "--clipboard" ]; then
  if command -v pbcopy &> /dev/null; then
    cat "$OUTPUT_FILE" | pbcopy
    echo "✅ Context exported to clipboard!"
  elif command -v xclip &> /dev/null; then
    cat "$OUTPUT_FILE" | xclip -selection clipboard
    echo "✅ Context exported to clipboard!"
  else
    echo "⚠️  Clipboard tool not found. Saved to: $OUTPUT_FILE"
  fi
else
  echo "✅ Context exported to: $OUTPUT_FILE"
fi

# Show file size
FILE_SIZE=$(wc -c < "$OUTPUT_FILE" | tr -d ' ')
echo "📊 Export size: $((FILE_SIZE / 1024)) KB"

# Show line count
LINE_COUNT=$(wc -l < "$OUTPUT_FILE" | tr -d ' ')
echo "📝 Total lines: $LINE_COUNT"

echo ""
echo "🔗 Next steps:"
echo "   1. Open Genspark AI Chat: https://genspark.ai"
echo "   2. Paste the exported context"
echo "   3. Ask unlimited questions"
echo "   4. Save responses to .sisyphus/genspark-responses/"
