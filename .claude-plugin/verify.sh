#!/bin/bash

# Content Discovery Plugin - Verification Script
# This script verifies the plugin structure and configuration

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Content Discovery Plugin Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"
ERRORS=0

# Function to check file exists
check_file() {
    if [ -f "$1" ]; then
        echo "✅ $1"
    else
        echo "❌ Missing: $1"
        ((ERRORS++))
    fi
}

# Function to check directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo "✅ $1/"
    else
        echo "❌ Missing directory: $1"
        ((ERRORS++))
    fi
}

echo "1. Checking Plugin Structure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_file "plugin.json"
check_file "README.md"
check_file "INSTALL.md"
check_file "CHANGELOG.md"
check_file "LICENSE"
check_file "marketplace.json"
check_file ".env.example"
check_file ".gitignore"
echo ""

echo "2. Checking Commands"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_dir "commands"
check_file "commands/discover.md"
check_file "commands/mission.md"
echo ""

echo "3. Checking Skills"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_dir "skills"
check_dir "skills/content-discovery"
check_file "skills/content-discovery/skill.md"
echo ""

echo "4. Checking Scripts"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_dir "scripts"
check_dir "scripts/discover"
check_dir "scripts/mission"
check_file "scripts/discover/check.sh"
check_file "scripts/discover/parse_tasks.sh"
check_file "scripts/discover/update_index.sh"
check_file "scripts/discover/image_utils.sh"
check_file "scripts/mission/show.sh"
check_file "scripts/mission/add.sh"
check_file "scripts/mission/update.sh"
check_file "scripts/mission/enable.sh"
check_file "scripts/mission/disable.sh"
check_file "scripts/mission/delete.sh"
echo ""

echo "5. Validating plugin.json"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if command -v jq &> /dev/null; then
    if jq empty plugin.json 2>/dev/null; then
        echo "✅ Valid JSON format"

        # Check required fields
        NAME=$(jq -r '.name' plugin.json)
        VERSION=$(jq -r '.version' plugin.json)
        DESC=$(jq -r '.description' plugin.json)

        echo "   Name: $NAME"
        echo "   Version: $VERSION"
        echo "   Description: $DESC"
    else
        echo "❌ Invalid JSON format in plugin.json"
        ((ERRORS++))
    fi
else
    echo "⚠️  jq not installed, skipping JSON validation"
fi
echo ""

echo "6. Validating marketplace.json"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if command -v jq &> /dev/null; then
    if jq empty marketplace.json 2>/dev/null; then
        echo "✅ Valid JSON format"

        # Check marketplace structure
        MARKETPLACE_NAME=$(jq -r '.marketplace.name' marketplace.json)
        PLUGIN_COUNT=$(jq '.plugins | length' marketplace.json)

        echo "   Marketplace: $MARKETPLACE_NAME"
        echo "   Plugins: $PLUGIN_COUNT"
    else
        echo "❌ Invalid JSON format in marketplace.json"
        ((ERRORS++))
    fi
else
    echo "⚠️  jq not installed, skipping JSON validation"
fi
echo ""

echo "7. Checking Script Permissions"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
SCRIPT_COUNT=0
EXEC_COUNT=0

for script in scripts/**/*.sh; do
    if [ -f "$script" ]; then
        ((SCRIPT_COUNT++))
        if [ -x "$script" ]; then
            ((EXEC_COUNT++))
            echo "✅ $script (executable)"
        else
            echo "⚠️  $script (not executable)"
        fi
    fi
done

echo ""
echo "   Total scripts: $SCRIPT_COUNT"
echo "   Executable: $EXEC_COUNT"

if [ $EXEC_COUNT -lt $SCRIPT_COUNT ]; then
    echo ""
    echo "   To fix permissions, run:"
    echo "   chmod +x scripts/**/*.sh"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Verification Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo "✅ All checks passed!"
    echo ""
    echo "Plugin is ready for:"
    echo "  • Local testing: /plugin install $PLUGIN_DIR"
    echo "  • Git repository publishing"
    echo "  • Marketplace submission"
    echo ""
    exit 0
else
    echo "❌ Found $ERRORS error(s)"
    echo ""
    echo "Please fix the errors above before:"
    echo "  • Installing the plugin"
    echo "  • Publishing to repository"
    echo "  • Submitting to marketplace"
    echo ""
    exit 1
fi
