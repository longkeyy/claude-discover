#!/bin/bash
# Show all tasks and their status

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Tasks Overview"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查任务目录
if [ ! -d "config/tasks" ]; then
    echo "⚠️  No tasks directory found"
    echo ""
    echo "Run: /mission add"
    exit 0
fi

# 列出所有任务
task_count=0
for task_file in config/tasks/*.md; do
    [ -e "$task_file" ] || continue
    [ "$(basename "$task_file")" = ".template.md" ] && continue

    task_id=$(basename "$task_file" .md)

    # 读取任务元数据
    enabled=$(grep "^enabled:" "$task_file" | awk '{print $2}' || echo "true")
    task_type=$(grep "^task_type:" "$task_file" | awk '{print $2}' || echo "unknown")
    title=$(grep "^# " "$task_file" | head -1 | sed 's/^# //')

    # 状态图标
    if [ "$enabled" = "true" ]; then
        task_status="✅"
    else
        task_status="⏸️"
    fi

    # 显示任务
    echo "$task_status $task_id [$task_type]"
    echo "   $title"

    # 最后运行时间和统计（从 tasks.index.yaml 读取）
    if [ -f "config/tasks.index.yaml" ]; then
        last_run=$(grep -A 3 "^  $task_id:" config/tasks.index.yaml | grep "last_run:" | awk '{print $2}' || echo "")
        total=$(grep -A 4 "^  $task_id:" config/tasks.index.yaml | grep "total_published:" | awk '{print $2}' || echo "")

        [ -n "$last_run" ] && echo "   Last run: $last_run"
        [ -n "$total" ] && echo "   Total published: $total posts"
    fi

    echo ""
    task_count=$((task_count + 1))
done

if [ $task_count -eq 0 ]; then
    echo "No tasks found."
    echo ""
    echo "Create your first task:"
    echo "  /mission add"
else
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Total: $task_count tasks"
    echo ""
    echo "Commands:"
    echo "  /mission add                 - Create new task"
    echo "  /mission update <task-id>    - Update task configuration"
    echo "  /mission enable <task-id>    - Enable task"
    echo "  /mission disable <task-id>   - Disable task"
    echo "  /mission delete <task-id>    - Delete task"
    echo "  /discover <task-id>          - Run discovery"
fi
