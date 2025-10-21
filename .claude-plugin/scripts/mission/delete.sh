#!/bin/bash
# Delete (archive) a task

set -e

TASK_ID="$1"

if [ -z "$TASK_ID" ]; then
    echo "❌ Error: Task ID required"
    echo "Usage: /mission delete <task-id>"
    exit 1
fi

TASK_FILE="config/tasks/${TASK_ID}.md"
KEYWORDS_FILE="config/keywords/${TASK_ID}.json"

if [ ! -f "$TASK_FILE" ]; then
    echo "❌ Error: Task not found: $TASK_ID"
    exit 1
fi

echo "⚠️  This will archive task: $TASK_ID"
echo ""
echo "Files to be archived:"
echo "  - $TASK_FILE"
[ -f "$KEYWORDS_FILE" ] && echo "  - $KEYWORDS_FILE"
echo ""
echo "Archived to: config/.archived/"
echo ""
read -p "Continue? (y/N): " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

# 创建归档目录
ARCHIVE_DIR="config/.archived/$(date +%Y-%m-%d)"
mkdir -p "$ARCHIVE_DIR/tasks"
mkdir -p "$ARCHIVE_DIR/keywords"

# 移动文件
mv "$TASK_FILE" "$ARCHIVE_DIR/tasks/${TASK_ID}.md"
[ -f "$KEYWORDS_FILE" ] && mv "$KEYWORDS_FILE" "$ARCHIVE_DIR/keywords/${TASK_ID}.json"

# 更新索引（移除任务）
if [ -f "config/tasks.index.yaml" ]; then
    # 备份索引
    cp config/tasks.index.yaml config/tasks.index.yaml.backup
    # 删除任务条目
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/^  $TASK_ID:/,/^  [a-z]/d" config/tasks.index.yaml
    else
        sed -i "/^  $TASK_ID:/,/^  [a-z]/d" config/tasks.index.yaml
    fi
fi

echo "✅ Task archived: $TASK_ID"
echo "   Location: $ARCHIVE_DIR/"
echo ""
echo "To restore:"
echo "  mv $ARCHIVE_DIR/tasks/${TASK_ID}.md config/tasks/"
echo "  mv $ARCHIVE_DIR/keywords/${TASK_ID}.json config/keywords/"
