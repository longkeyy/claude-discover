#!/bin/bash
# Disable a task

set -e

TASK_ID="$1"

if [ -z "$TASK_ID" ]; then
    echo "❌ Error: Task ID required"
    echo "Usage: /mission disable <task-id>"
    exit 1
fi

TASK_FILE="config/tasks/${TASK_ID}.md"

if [ ! -f "$TASK_FILE" ]; then
    echo "❌ Error: Task not found: $TASK_ID"
    exit 1
fi

# 更新配置文件
if grep -q "^enabled:" "$TASK_FILE"; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' 's/^enabled: true/enabled: false/' "$TASK_FILE"
    else
        sed -i 's/^enabled: true/enabled: false/' "$TASK_FILE"
    fi
else
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' '/^---$/a\
enabled: false
' "$TASK_FILE"
    else
        sed -i '/^---$/a\enabled: false' "$TASK_FILE"
    fi
fi

# 更新索引
if [ -f "config/tasks.index.yaml" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "/^  $TASK_ID:/,/^  [a-z]/ s/status: active/status: paused/" config/tasks.index.yaml
    else
        sed -i "/^  $TASK_ID:/,/^  [a-z]/ s/status: active/status: paused/" config/tasks.index.yaml
    fi
fi

echo "⏸️  Task disabled: $TASK_ID"
