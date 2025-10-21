---
description: Execute discovery task - scan, analyze, and publish content
argument-hint: "[task-id or 'all'] [--parallel|--serial]"
---

# Content Discovery Executor

执行内容发现任务：扫描数据源 → 智能分析 → 发布内容 → 优化关键词

## User Arguments: $ARGUMENTS

## Usage

```bash
# 执行所有启用的任务（默认并行）
/discover

# 并行执行指定任务（推荐，速度快）
/discover prompt-papers mcp-servers foundation-models

# 串行执行指定任务
/discover --serial prompt-papers mcp-servers

# 执行单个任务
/discover prompt-papers

# 执行所有任务（显式）
/discover all

# 强制并行执行（默认行为）
/discover --parallel all
```

---

## 执行模式

### 并行模式（默认）
- **优势**：多个任务同时执行，速度快，节省时间
- **适用**：大多数情况，特别是执行多个独立任务时
- **实现**：使用 Claude Code 的并行 Skill 调用能力

### 串行模式
- **优势**：按顺序执行，便于调试和观察每个任务的详细输出
- **适用**：调试、学习流程、资源受限环境
- **实现**：顺序调用 Skill

---

## Step 1: 前置检查

```bash
bash scripts/discover/check.sh || exit 1
```

---

## Step 2: 解析任务列表

```bash
# 解析参数，提取执行模式和任务列表
EXEC_MODE="parallel"  # 默认并行
TASK_ARGS="$ARGUMENTS"

# 检查是否指定了执行模式
if [[ "$ARGUMENTS" =~ --serial ]]; then
  EXEC_MODE="serial"
  TASK_ARGS=$(echo "$ARGUMENTS" | sed 's/--serial//g' | xargs)
elif [[ "$ARGUMENTS" =~ --parallel ]]; then
  EXEC_MODE="parallel"
  TASK_ARGS=$(echo "$ARGUMENTS" | sed 's/--parallel//g' | xargs)
fi

# 解析任务列表
TASKS_TO_RUN=$(bash scripts/discover/parse_tasks.sh "$TASK_ARGS")

# 检查是否有任务
if [ -z "$TASKS_TO_RUN" ]; then
  echo "⚠️  没有启用的任务"
  echo ""
  echo "请启用任务："
  echo "  /mission enable <task-id>"
  echo ""
  echo "或创建新任务："
  echo "  /mission add"
  exit 0
fi

# 显示任务列表
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 任务列表"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "执行模式: $EXEC_MODE"
echo ""
echo "待执行任务:"
echo "$TASKS_TO_RUN" | tr ' ' '\n' | while read task; do
  [ -n "$task" ] && echo "  • $task"
done
echo ""
```

---

## Step 3: 准备执行环境

```bash
# 为每个任务准备会话目录
task_count=0
for task_id in $TASKS_TO_RUN; do
  [ -z "$task_id" ] && continue

  SESSION_ID="$(date +%Y-%m-%d_%H%M%S)_${task_count}"
  SESSION_DIR="temp/sessions/${task_id}/${SESSION_ID}"
  mkdir -p "$SESSION_DIR"

  echo "准备任务: $task_id (会话: $SESSION_ID)"
  ((task_count++))
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 开始执行内容发现"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$EXEC_MODE" = "parallel" ]; then
  echo "⚡ 并行模式：所有任务将同时执行"
  echo "准备调用 $task_count 个 content-discovery skills..."
else
  echo "📝 串行模式：任务将按顺序执行"
fi

echo ""
echo "任务详情: $TASKS_TO_RUN"
echo ""
```

---

## Step 4: 执行发现任务

现在 Claude 将自动调用 **content-discovery** skill 来处理每个任务。

### 并行执行模式

如果是并行模式 (`--parallel` 或默认)，需要在**单个响应**中为每个任务创建独立的 content-discovery skill 调用。

### 串行执行模式

如果是串行模式 (`--serial`)，按顺序为每个任务调用 content-discovery skill。

### 任务配置信息

每个任务需要传递以下信息给 content-discovery skill：

```
任务ID: {task_id}
执行模式: {EXEC_MODE}
任务配置: config/tasks/{task_id}.md
关键词配置: config/keywords/{task_id}.json
会话目录: temp/sessions/{task_id}/{session_id}/
输出目录: posts/{task_id}/
```

content-discovery skill 将完成以下工作：
1. 检测并选择数据源（MCP 优先，fallback WebSearch）
2. 搜索和过滤内容（应用关键词和过滤规则）
3. AI 语义去重（对比已发布内容）
4. 分析和评估质量（生成中文摘要，提取元数据）
5. 提取和下载图片（封面、截图、架构图）
6. 发布到配置的渠道（Hexo/Telegram/Discord）
7. 验证发布质量
8. 优化关键词

---

## Step 5: 更新任务索引

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 更新任务索引"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 为每个任务更新索引
for task_id in $TASKS_TO_RUN; do
  [ -z "$task_id" ] && continue

  # 统计本次发布数量（最近30分钟内创建的文件）
  SESSION_POSTS=$(find "posts/${task_id}/" -name "*.json" -mmin -30 2>/dev/null | wc -l | xargs)

  # 更新索引
  bash scripts/discover/update_index.sh "$task_id" "$SESSION_POSTS"
done

echo ""
```

---

## Step 6: 执行总结

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 内容发现完成"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 统计
task_count=$(echo "$TASKS_TO_RUN" | wc -w | xargs)
total_posts=$(find posts -name "*.json" -type f 2>/dev/null | wc -l | xargs)
new_posts=$(find posts -name "*.json" -mmin -30 2>/dev/null | wc -l | xargs)

echo "执行统计:"
echo "  执行模式: $EXEC_MODE"
echo "  任务数: $task_count"
echo "  总发布数: $total_posts"
echo "  本次新增: $new_posts"
echo ""

echo "查看结果:"
echo "  • 发布内容: posts/<task-id>/"
echo "  • 会话日志: temp/sessions/<task-id>/"
echo "  • 关键词建议: config/keywords/<task-id>.json"
echo "  • 任务状态: /mission show"
echo ""

if [ "$EXEC_MODE" = "parallel" ]; then
  echo "💡 提示: 并行执行已完成，如需查看详细日志可使用串行模式"
  echo "   /discover --serial <task-ids>"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

---

## 错误处理

```bash
# 如果执行失败
echo "❌ 错误：任务执行失败"
echo ""
echo "可能原因："
echo "  - 网络连接问题"
echo "  - MCP 服务不可用"
echo "  - 数据源访问受限"
echo "  - 配置文件格式错误"
echo ""
echo "排查步骤："
echo "  1. 检查网络连接"
echo "  2. 验证任务配置: cat config/tasks/<task-id>.md"
echo "  3. 查看会话日志: temp/sessions/<task-id>/"
echo "  4. 使用串行模式重试: /discover --serial <task-id>"
echo ""
```

---

## 性能对比

| 模式 | 3个任务执行时间 | 适用场景 |
|------|----------------|----------|
| **并行** | ~5-8 分钟 | 日常使用、多任务执行 |
| **串行** | ~15-20 分钟 | 调试、详细日志 |

**建议**：默认使用并行模式，速度快3-4倍。

---

## Notes

- **Skill 驱动**: 使用 content-discovery skill 处理所有发现逻辑
- **并行优先**: 默认并行执行，充分利用 Claude Code 的多 Skill 能力
- **脚本化**: 使用 scripts/discover/ 下的独立脚本，便于维护和测试
- **MCP 优先**: 自动检测并优先使用 MCP 服务
- **AI 语义去重**: 通过文件名语义判断，不依赖 URL
- **自动关键词**: 每次运行自动发现新关键词
- **会话隔离**: 每次执行创建独立会话目录
- **灵活模式**: 支持并行和串行两种执行模式
