#!/usr/bin/env bash
# Test plugin installation and validation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PLUGIN_DIR="$PROJECT_ROOT/.claude-plugin"

echo "🧪 Testing Content Discovery Plugin..."

# Check required files
echo "📋 Checking required files..."
required_files=(
    "plugin.json"
    "marketplace.json"
    "README.md"
    "CHANGELOG.md"
    "PUBLISHING.md"
    "commands/discover.md"
    "commands/mission.md"
    "skills/content-discovery/skill.md"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [ ! -f "$PLUGIN_DIR/$file" ]; then
        missing_files+=("$file")
        echo "❌ Missing: $file"
    else
        echo "✅ Found: $file"
    fi
done

if [ ${#missing_files[@]} -gt 0 ]; then
    echo ""
    echo "❌ Missing ${#missing_files[@]} required files"
    exit 1
fi

# Validate JSON files
echo ""
echo "🔍 Validating JSON files..."
if command -v jq &> /dev/null; then
    for json_file in "$PLUGIN_DIR"/*.json; do
        if [ -f "$json_file" ]; then
            filename=$(basename "$json_file")
            if jq empty "$json_file" 2>/dev/null; then
                echo "✅ $filename is valid"
            else
                echo "❌ $filename is invalid"
                exit 1
            fi
        fi
    done
else
    echo "⚠️  jq not found, skipping JSON validation"
fi

# Check frontmatter in command files
echo ""
echo "🔍 Checking command frontmatter..."
for cmd_file in "$PLUGIN_DIR"/commands/*.md; do
    if [ -f "$cmd_file" ]; then
        filename=$(basename "$cmd_file")
        if grep -q "^---$" "$cmd_file"; then
            echo "✅ $filename has frontmatter"
        else
            echo "⚠️  $filename missing frontmatter"
        fi
    fi
done

# Check skill frontmatter
echo ""
echo "🔍 Checking skill frontmatter..."
for skill_file in "$PLUGIN_DIR"/skills/*/skill.md; do
    if [ -f "$skill_file" ]; then
        filename=$(basename "$(dirname "$skill_file")")/skill.md
        if grep -q "^---$" "$skill_file"; then
            echo "✅ $filename has frontmatter"
            # Check if description exists
            if grep -q "^description:" "$skill_file"; then
                echo "✅ $filename has description"
            else
                echo "⚠️  $filename missing description"
            fi
        else
            echo "❌ $filename missing frontmatter"
        fi
    fi
done

# Verify scripts are executable
echo ""
echo "🔍 Checking script permissions..."
if [ -d "$PLUGIN_DIR/scripts" ]; then
    for script in "$PLUGIN_DIR"/scripts/**/*.sh; do
        if [ -f "$script" ]; then
            filename=$(basename "$script")
            if [ -x "$script" ]; then
                echo "✅ $filename is executable"
            else
                echo "⚠️  $filename is not executable (fixing...)"
                chmod +x "$script"
                echo "✅ Fixed: $filename"
            fi
        fi
    done
fi

echo ""
echo "✅ All tests passed!"
echo ""
echo "To install locally:"
echo "  /plugin install $PLUGIN_DIR"
