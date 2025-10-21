#!/bin/bash
# Create a new task

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Create New Task"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 调用 product-strategy-manager agent
echo "Starting interactive task creation..."
echo ""
echo "The agent will guide you through:"
echo "  1. Task ID and type (paper/project/model/dataset)"
echo "  2. Data sources (ArXiv/GitHub/HuggingFace)"
echo "  3. Topics and keywords"
echo "  4. Filter rules"
echo "  5. Publishing targets (Hexo/Telegram/Discord)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# TODO: 调用 agent
echo "⚠️  Agent integration pending"
echo ""
echo "For now, manually create:"
echo "  1. Copy template: cp config/tasks/.template.md config/tasks/my-task.md"
echo "  2. Edit configuration: vim config/tasks/my-task.md"
echo "  3. Create keywords: cp config/keywords/.templates/default.json config/keywords/my-task.json"
echo "  4. Update index: update config/tasks.index.yaml"
