# Discover Scripts

辅助 `/discover` 命令执行的脚本集合。

## 脚本列表

### check.sh
**功能**：前置检查
- 验证任务目录存在
- 创建必要的工作目录（temp、posts、logs）
- 返回检查结果

**用法**：
```bash
bash scripts/discover/check.sh
```

### parse_tasks.sh
**功能**：解析任务列表
- 接受参数：任务ID列表或 "all"
- 返回要执行的任务ID（每行一个）
- 自动过滤已禁用的任务

**用法**：
```bash
# 解析所有启用的任务
bash scripts/discover/parse_tasks.sh

# 解析指定任务
bash scripts/discover/parse_tasks.sh "task1 task2"

# 解析所有任务（显式）
bash scripts/discover/parse_tasks.sh "all"
```

### update_index.sh
**功能**：更新任务索引
- 更新 config/tasks.index.yaml
- 记录执行时间和发布数量
- 累计总发布数

**用法**：
```bash
bash scripts/discover/update_index.sh <task_id> <published_count>
```

**示例**：
```bash
# 更新 prompt-papers 任务，本次发布 7 篇
bash scripts/discover/update_index.sh prompt-papers 7
```

## 并行执行支持

`/discover` 命令支持并行执行多个任务：

1. **自动并行**：默认情况下，所有任务会并行执行
2. **手动控制**：使用 `--serial` 参数强制串行执行

**示例**：
```bash
# 并行执行所有任务（默认）
/discover

# 并行执行指定任务
/discover task1 task2 task3

# 串行执行（按顺序）
/discover --serial task1 task2
```

## 集成方式

这些脚本由 `/discover` 命令自动调用，无需手动执行。workflow如下：

```
1. check.sh           → 前置检查
2. parse_tasks.sh     → 解析任务列表
3. (并行) Agent执行   → 调用 data-pipeline-architect
4. update_index.sh    → 更新任务索引（每个任务完成后）
5. 生成总结报告
```

## 错误处理

所有脚本使用 `set -e`，遇到错误会立即退出。

常见错误：
- **任务目录不存在**：运行 `/mission add` 创建任务
- **任务文件格式错误**：检查 YAML frontmatter
- **权限问题**：确保脚本有执行权限 (`chmod +x`)
