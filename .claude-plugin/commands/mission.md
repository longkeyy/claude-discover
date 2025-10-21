---
description: Task management - create, configure, and manage discovery tasks
argument-hint: [show | add | update <task-id> | enable <task-id> | disable <task-id> | delete <task-id>]
---

# Task Management

管理内容发现任务：创建、配置、启用、禁用和删除任务。

## User Arguments: $ARGUMENTS

---

## 执行命令

解析命令参数并调用相应的脚本。

```bash
COMMAND=$(echo "$ARGUMENTS" | awk '{print $1}')
TASK_ID=$(echo "$ARGUMENTS" | awk '{print $2}')

# 默认命令是 show
if [[ -z "$COMMAND" || "$COMMAND" =~ ^(show|list|ls|显示|查看)$ ]]; then
    bash scripts/mission/show.sh
    exit $?
fi

# add - 创建新任务
if [[ "$COMMAND" =~ ^(add|create|new|添加|创建)$ ]]; then
    bash scripts/mission/add.sh
    exit $?
fi

# update - 更新任务配置
if [[ "$COMMAND" =~ ^(update|edit|modify|更新|编辑|修改)$ ]]; then
    bash scripts/mission/update.sh "$TASK_ID"
    exit $?
fi

# enable - 启用任务
if [[ "$COMMAND" =~ ^(enable|启用|激活)$ ]]; then
    bash scripts/mission/enable.sh "$TASK_ID"
    exit $?
fi

# disable - 禁用任务
if [[ "$COMMAND" =~ ^(disable|pause|禁用|暂停)$ ]]; then
    bash scripts/mission/disable.sh "$TASK_ID"
    exit $?
fi

# delete - 删除任务（归档）
if [[ "$COMMAND" =~ ^(delete|remove|rm|删除)$ ]]; then
    bash scripts/mission/delete.sh "$TASK_ID"
    exit $?
fi

# 未知命令
echo "❌ Unknown command: $COMMAND"
echo ""
echo "Usage:"
echo "  /mission              - Show all tasks"
echo "  /mission add          - Create new task"
echo "  /mission update ID    - Update task configuration"
echo "  /mission enable ID    - Enable task"
echo "  /mission disable ID   - Disable task"
echo "  /mission delete ID    - Delete task (archive)"
echo ""
echo "Examples:"
echo "  /mission show"
echo "  /mission add"
echo "  /mission update prompt-papers"
echo "  /mission enable prompt-papers"
echo "  /mission disable golang-projects"
echo "  /mission delete old-task"
exit 1
```

---

## 脚本说明

所有任务管理逻辑都在 `scripts/mission/` 目录下：

- **show.sh** - 显示所有任务及其状态
- **add.sh** - 创建新任务（交互式）
- **update.sh** - 更新任务配置
- **enable.sh** - 启用任务
- **disable.sh** - 禁用任务
- **delete.sh** - 删除任务（移动到归档）

每个脚本都是独立的，可以单独测试和维护。

---

## 文件结构

```
config/
├── tasks.index.yaml        # 任务索引（自动维护）
├── tasks/
│   ├── .template.md       # 任务模板
│   ├── prompt-papers.md   # 任务配置
│   └── mcp-servers.md
├── keywords/
│   ├── .templates/
│   │   └── default.json
│   ├── prompt-papers.json
│   └── mcp-servers.json
└── .archived/             # 归档
    └── 2025-10-11/
        ├── tasks/
        └── keywords/

scripts/
└── mission/
    ├── show.sh           # 显示任务列表
    ├── add.sh            # 创建新任务
    ├── update.sh         # 更新任务
    ├── enable.sh         # 启用任务
    ├── disable.sh        # 禁用任务
    └── delete.sh         # 删除任务
```

---

## 任务配置示例

详见 `config/tasks/.template.md` 和现有任务配置文件。
