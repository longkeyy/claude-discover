#!/bin/bash
# 解析任务列表：确定要执行的任务

set -e

PROJECT_ROOT="$(pwd)"
ARGUMENTS="$1"

# 如果用户指定了任务ID
if [ -n "$ARGUMENTS" ]; then
  # 检查是否是 "all" 或 "全部"
  if [[ "$ARGUMENTS" =~ ^(all|全部|所有)$ ]]; then
    echo "执行所有启用的任务"
    # 查找所有启用的任务
    for task_file in "$PROJECT_ROOT/config/tasks"/*.md; do
      [ "$task_file" = "$PROJECT_ROOT/config/tasks/.template.md" ] && continue
      [ -f "$task_file" ] || continue

      if grep -q "^enabled: true" "$task_file" 2>/dev/null; then
        basename "$task_file" .md
      fi
    done
  else
    # 直接使用参数作为任务ID列表
    echo "$ARGUMENTS"
  fi
else
  # 默认执行所有启用的任务
  echo "未指定任务，执行所有启用的任务" >&2
  for task_file in "$PROJECT_ROOT/config/tasks"/*.md; do
    [ "$task_file" = "$PROJECT_ROOT/config/tasks/.template.md" ] && continue
    [ -f "$task_file" ] || continue

    if grep -q "^enabled: true" "$task_file" 2>/dev/null; then
      basename "$task_file" .md
    fi
  done
fi
