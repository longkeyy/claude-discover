# Mission 脚本说明

本目录包含 `/mission` 命令的所有子命令实现脚本。

## 📁 文件列表

| 脚本 | 功能 | 用法 |
|------|------|------|
| `show.sh` | 显示所有任务及状态 | `bash show.sh` |
| `add.sh` | 创建新任务 | `bash add.sh` |
| `update.sh` | 更新任务配置 | `bash update.sh <task-id>` |
| `enable.sh` | 启用任务 | `bash enable.sh <task-id>` |
| `disable.sh` | 禁用任务 | `bash disable.sh <task-id>` |
| `delete.sh` | 删除任务（归档） | `bash delete.sh <task-id>` |

## 🎯 设计原则

### 为什么要提取成独立脚本？

1. **避免语法问题**：内联 bash 脚本在 markdown 中容易出现转义和变量冲突问题
2. **更易测试**：每个脚本都可以独立运行和测试
3. **更易维护**：修改逻辑时只需编辑对应脚本文件
4. **可复用**：脚本可以被其他工具或命令调用
5. **更清晰**：命令定义文件（mission.md）只负责分发，逻辑在脚本中

### 脚本设计规范

所有脚本都遵循以下规范：

1. **错误处理**：使用 `set -e` 在错误时立即退出
2. **参数验证**：必需参数缺失时显示清晰的错误信息
3. **跨平台兼容**：macOS 和 Linux 的 sed 命令差异已处理
4. **用户友好**：清晰的提示信息和交互式确认
5. **安全归档**：删除操作移动到归档而非直接删除

## 🔧 使用示例

### 直接调用脚本

```bash
# 显示所有任务
bash scripts/mission/show.sh

# 启用任务
bash scripts/mission/enable.sh prompt-papers

# 禁用任务
bash scripts/mission/disable.sh mcp-servers
```

### 通过 /mission 命令调用

```bash
# 显示任务（默认）
/mission
/mission show

# 启用/禁用任务
/mission enable prompt-papers
/mission disable mcp-servers

# 更新任务
/mission update prompt-papers

# 删除任务（会提示确认）
/mission delete old-task
```

## 📝 添加新命令

如果需要添加新的子命令：

1. 在 `scripts/mission/` 创建新脚本文件
2. 添加执行权限：`chmod +x scripts/mission/new-command.sh`
3. 在 `.claude/commands/mission.md` 添加命令分发逻辑：

```bash
if [[ "$COMMAND" =~ ^(new-command|别名)$ ]]; then
    bash scripts/mission/new-command.sh "$TASK_ID"
    exit $?
fi
```

## 🐛 调试

如果命令执行有问题：

1. **直接运行脚本**：可以看到详细的错误信息
   ```bash
   bash scripts/mission/show.sh
   ```

2. **检查权限**：确保脚本有执行权限
   ```bash
   ls -l scripts/mission/*.sh
   ```

3. **检查路径**：脚本假设在项目根目录运行
   ```bash
   pwd  # 应该显示项目根目录
   ```

## 📚 相关文档

- [任务配置说明](../../config/tasks/.template.md)
- [关键词配置](../../config/keywords/.templates/default.json)
- [发现命令](../../.claude/commands/discover.md)
