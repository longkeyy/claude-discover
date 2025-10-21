#!/bin/bash
# Enable a task

set -e

TASK_ID="$1"

if [ -z "$TASK_ID" ]; then
    echo "❌ Error: Task ID required"
    echo "Usage: /mission enable <task-id>"
    exit 1
fi

TASK_FILE="config/tasks/${TASK_ID}.md"

if [ ! -f "$TASK_FILE" ]; then
    echo "❌ Error: Task not found: $TASK_ID"
    echo ""
    echo "Available tasks:"
    ls config/tasks/*.md 2>/dev/null | grep -v ".template.md" | xargs -n1 basename | sed 's/.md$//' | sed 's/^/  - /'
    exit 1
fi

# 更新配置文件
if grep -q "^enabled:" "$TASK_FILE"; then
    # macOS 需要 -i '' 参数
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's/^enabled: false/enabled: true/' "$TASK_FILE"
    else
        sed -i 's/^enabled: false/enabled: true/' "$TASK_FILE"
    fi
else
    # 如果没有 enabled 字段，在 front matter 中添加
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' '/^---$/a\
enabled: true
' "$TASK_FILE"
    else
        sed -i '/^---$/a\enabled: true' "$TASK_FILE"
    fi
fi

# 更新索引
if [ -f "config/tasks.index.yaml" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/^  $TASK_ID:/,/^  [a-z]/ s/status: paused/status: active/" config/tasks.index.yaml
    else
        sed -i "/^  $TASK_ID:/,/^  [a-z]/ s/status: paused/status: active/" config/tasks.index.yaml
    fi
fi

echo "✅ Task enabled: $TASK_ID"
echo ""
echo "Run: /discover $TASK_ID"
