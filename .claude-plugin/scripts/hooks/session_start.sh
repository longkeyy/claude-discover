#!/bin/bash
# Session Start Hook - Load project context
# This hook runs when Claude Code starts a new session

set -e

# Only run if config directory exists
if [ ! -d "config" ]; then
  exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Content Discovery Plugin"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Show active tasks
if [ -f "config/tasks.index.yaml" ]; then
  ENABLED_COUNT=$(grep -c "enabled: true" config/tasks.index.yaml 2>/dev/null || echo "0")
  TOTAL_COUNT=$(grep -c "^  [a-z]" config/tasks.index.yaml 2>/dev/null || echo "0")

  echo "📊 Task Status:"
  echo "  • Total tasks: $TOTAL_COUNT"
  echo "  • Enabled tasks: $ENABLED_COUNT"
  echo ""
fi

# Show recent activity
if [ -d "posts" ]; then
  RECENT_POSTS=$(find posts -name "*.json" -mtime -1 2>/dev/null | wc -l | xargs)
  if [ "$RECENT_POSTS" -gt 0 ]; then
    echo "📰 Recent Activity (last 24h):"
    echo "  • New posts: $RECENT_POSTS"
    echo ""
  fi
fi

echo "💡 Quick Commands:"
echo "  • /mission          - View and manage tasks"
echo "  • /discover         - Run content discovery"
echo "  • /discover all     - Run all enabled tasks"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0
