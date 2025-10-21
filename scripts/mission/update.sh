#!/bin/bash
# Update task configuration

set -e

TASK_ID="$1"

if [ -z "$TASK_ID" ]; then
    echo "❌ Error: Task ID required"
    echo "Usage: /mission update <task-id>"
    exit 1
fi

TASK_FILE="config/tasks/${TASK_ID}.md"
KEYWORDS_FILE="config/keywords/${TASK_ID}.json"

if [ ! -f "$TASK_FILE" ]; then
    echo "❌ Error: Task not found: $TASK_ID"
    echo ""
    echo "Available tasks:"
    ls config/tasks/*.md 2>/dev/null | grep -v ".template.md" | xargs -n1 basename | sed 's/.md$//' | sed 's/^/  - /'
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Update Task: $TASK_ID"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 显示当前任务信息
task_type=$(grep "^task_type:" "$TASK_FILE" | awk '{print $2}' || echo "unknown")
enabled=$(grep "^enabled:" "$TASK_FILE" | awk '{print $2}' || echo "true")
title=$(grep "^# " "$TASK_FILE" | head -1 | sed 's/^# //')

echo "Current Configuration:"
echo "  Task ID:   $TASK_ID"
echo "  Type:      $task_type"
echo "  Status:    $enabled"
echo "  Title:     $title"
echo ""

# 提供更新选项
echo "What would you like to update?"
echo ""
echo "  1) Edit task file directly      ($TASK_FILE)"
[ -f "$KEYWORDS_FILE" ] && echo "  2) Edit keywords file           ($KEYWORDS_FILE)"
echo "  3) Interactive update (guided)"
echo "  4) Cancel"
echo ""
read -p "Select option (1-4): " choice

case $choice in
    1)
        # 打开任务文件编辑
        if [ -n "$EDITOR" ]; then
            $EDITOR "$TASK_FILE"
        elif command -v vim &> /dev/null; then
            vim "$TASK_FILE"
        elif command -v nano &> /dev/null; then
            nano "$TASK_FILE"
        else
            echo "⚠️  No editor found. Set \$EDITOR or install vim/nano"
            echo ""
            echo "File location: $TASK_FILE"
            exit 1
        fi
        echo "✅ Task configuration updated"
        ;;
    2)
        if [ ! -f "$KEYWORDS_FILE" ]; then
            echo "⚠️  Keywords file not found: $KEYWORDS_FILE"
            echo ""
            echo "Create from template?"
            read -p "(y/N): " create_kw
            if [[ "$create_kw" =~ ^[Yy]$ ]]; then
                mkdir -p "config/keywords"
                if [ -f "config/keywords/.templates/default.json" ]; then
                    cp "config/keywords/.templates/default.json" "$KEYWORDS_FILE"
                else
                    echo '{"topics": [], "keywords": [], "exclude": []}' > "$KEYWORDS_FILE"
                fi
            else
                exit 0
            fi
        fi

        # 打开关键词文件编辑
        if [ -n "$EDITOR" ]; then
            $EDITOR "$KEYWORDS_FILE"
        elif command -v vim &> /dev/null; then
            vim "$KEYWORDS_FILE"
        elif command -v nano &> /dev/null; then
            nano "$KEYWORDS_FILE"
        else
            echo "⚠️  No editor found. Set \$EDITOR or install vim/nano"
            echo ""
            echo "File location: $KEYWORDS_FILE"
            exit 1
        fi
        echo "✅ Keywords configuration updated"
        ;;
    3)
        # 交互式更新
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "🤖 Interactive Update Mode"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "The agent will guide you through updating:"
        echo "  • Task metadata (type, status, etc.)"
        echo "  • Data sources configuration"
        echo "  • Topics and keywords"
        echo "  • Filter rules"
        echo "  • Publishing settings"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        # TODO: 调用 agent 进行交互式更新
        echo "⚠️  Agent integration pending"
        echo ""
        echo "For now, please use option 1 or 2 to edit files directly."
        ;;
    4)
        echo "Cancelled."
        exit 0
        ;;
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "Updated task: $TASK_ID"
echo ""
echo "View changes:"
echo "  /mission show"
echo ""
echo "Test task:"
echo "  /discover $TASK_ID"
