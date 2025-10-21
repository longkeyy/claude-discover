# Changelog

所有重要的项目变更都记录在这个文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [3.0.0] - 2025-10-20

### 🎉 发布为 Claude Code Plugin

#### Added - 新增功能

**Plugin 支持**：
- 创建完整的 `.claude-plugin/` 目录结构
- 添加 `plugin.json` 配置文件，定义 plugin 元数据
- 添加 `marketplace.json` 支持 marketplace 发布
- 创建独立的 Plugin README、INSTALL 和 CHANGELOG 文档
- 添加 `.env.example` 环境变量模板
- 添加 `verify.sh` 脚本用于验证 plugin 结构

**Plugin 功能**：
- 一键安装：`/plugin install content-discovery`
- 完整打包了 commands、skills 和 scripts
- 支持环境变量配置
- 清晰的依赖声明（MCP servers, Hexo 等）

**文档完善**：
- Plugin 使用指南（`.claude-plugin/README.md`）
- 详细安装说明（`.claude-plugin/INSTALL.md`）
- Plugin 版本历史（`.claude-plugin/CHANGELOG.md`）
- 项目 README 更新，添加 Plugin 安装方式

#### Changed - 变更

**项目结构**：
```diff
claude-discover/
  ├── .claude/                      # 原有项目配置
  │   ├── commands/
  │   └── skills/
+ └── .claude-plugin/                # 新增 Plugin 目录
+     ├── plugin.json                # Plugin 配置
+     ├── marketplace.json           # Marketplace 配置
+     ├── README.md                  # Plugin 文档
+     ├── INSTALL.md                 # 安装指南
+     ├── CHANGELOG.md               # Plugin 版本历史
+     ├── LICENSE                    # MIT License
+     ├── .env.example               # 环境变量模板
+     ├── .gitignore                 # Plugin 忽略文件
+     ├── verify.sh                  # 验证脚本
+     ├── commands/                  # 打包的 commands
+     ├── skills/                    # 打包的 skills
+     └── scripts/                   # 打包的 scripts
```

**使用方式增强**：
- 原有方式：克隆项目直接使用（适合开发）
- 新增方式：Plugin 安装（推荐，便于分发）

#### Technical Details

**Plugin 架构**：
- 遵循 Claude Code 官方 plugin 规范
- 支持本地安装和 marketplace 发布
- 完整的依赖管理和环境配置
- 自动化验证脚本确保 plugin 完整性

**兼容性**：
- 保持原有项目结构不变
- Plugin 是项目的打包分发形式
- 两种使用方式可以共存

---

## [2.0.0] - 2025-10-19

### 🎯 架构重构：从 Agent 迁移到 Skill

#### Changed - 重大变更

**架构调整**：
- 从 `data-pipeline-architect` Agent 迁移到 `content-discovery` Skill
- 简化 `discover.md` command，移除详细业务逻辑
- 建立清晰的 **Command + Skill** 架构模式

**目录结构变化**：
```diff
.claude/
- ├── agents/
- │   └── data-pipeline-architect.md  # 移除
  ├── commands/
  │   ├── mission.md
- │   └── discover.md                 # 简化，只保留流程编排
+ │   └── discover.md                 # 新版：触发 Skill
+ └── skills/
+     └── content-discovery/
+         ├── skill.md                 # 新增：所有业务逻辑
+         └── helpers/
```

#### Why - 为什么重构

**之前的问题**：
1. ❌ Agent 名称 "data-pipeline-architect" 与实际功能不匹配
2. ❌ Claude 可能在不相关的数据管道任务中错误调用
3. ❌ 不符合 Claude Code 最佳实践
4. ❌ Agent 通常用于"咨询专家"，不是执行完整工作流

**改进后**：
1. ✅ Skill 名称 "content-discovery" 准确描述功能
2. ✅ description 明确说明使用场景（ArXiv/GitHub/HuggingFace）
3. ✅ 符合官方最佳实践（Skills 用于模块化能力）
4. ✅ 可在不同上下文中复用
5. ✅ 职责清晰：Command 编排，Skill 执行

#### Added - 新增内容

- 📄 `.claude/skills/content-discovery/skill.md` - 内容发现核心逻辑
  - 完整的 5 阶段工作流
  - 数据源检测 → 搜索过滤 → 分析评估 → 发布 → 验证
  - 支持并行执行多个任务

- 📚 `ARCHITECTURE.md` - 架构设计文档
  - Command + Skill 模式说明
  - 设计决策和原理
  - 与官方文档对照
  - 未来扩展指南

#### Improved - 改进内容

- 📝 `README.md` - 更新架构说明
  - 新增 Commands vs Skills 对比
  - 更新目录结构图
  - 添加架构说明部分

- ⚡ `.claude/commands/discover.md` - 简化逻辑
  - 从 650 行简化到 280 行
  - 只保留流程编排（前置检查、参数解析、环境准备）
  - 移除业务逻辑到 Skill
  - 添加 Skill 触发说明

#### Removed - 移除内容

- 🗑️ `.claude/agents/data-pipeline-architect.md` - 移除旧 Agent
  - 职责转移到 content-discovery Skill
  - 避免命名混淆

### 技术细节

**Skill YAML Frontmatter**：
```yaml
---
name: content-discovery
description: |
  Automated content discovery workflow for scanning multiple data sources
  (ArXiv, GitHub, HuggingFace), applying AI-powered semantic filtering...

  Use this skill when:
  - Executing /discover command with task configurations
  - Scanning academic papers from ArXiv (via MCP or WebSearch)
  - Finding GitHub repositories or HuggingFace models
  ...
---
```

**Command 触发 Skill 的方式**：
```markdown
## Step 4: 执行发现任务

现在 Claude 将自动调用 **content-discovery** skill 来处理每个任务。

每个任务需要传递以下信息给 content-discovery skill：
- 任务ID: {task_id}
- 执行模式: {EXEC_MODE}
- 任务配置: config/tasks/{task_id}.md
...
```

### 向后兼容性

✅ **完全兼容**：
- 用户接口不变（`/mission`, `/discover` 命令保持一致）
- 配置文件格式不变（`config/tasks/*.md`）
- 脚本调用方式不变（`scripts/discover/*.sh`）
- 执行模式不变（并行/串行）

唯一变化是**内部实现**从 Agent 迁移到 Skill，对用户透明。

### 升级指南

无需任何操作。如果你是从旧版本升级：

1. 删除旧的 `.claude/agents/` 目录（如果存在）
2. 确认新的 `.claude/skills/content-discovery/` 目录存在
3. 执行 `/discover` 测试功能正常

### 性能影响

✅ **无性能影响**：
- 执行逻辑完全相同
- 并行模式仍然 3-4 倍于串行模式
- 内存占用无变化

### 参考资源

- [Claude Code Skills 官方文档](https://docs.claude.com/en/docs/claude-code/skills)
- [Claude Code 最佳实践](https://www.anthropic.com/engineering/claude-code-best-practices)
- [ARCHITECTURE.md](./ARCHITECTURE.md) - 详细架构设计文档

---

## [1.0.0] - 2025-10-11

### Added
- 🎉 初始版本发布
- ✨ 基于 Agent 的内容发现系统
- 📋 `/mission` 任务管理命令
- 🔍 `/discover` 内容发现命令
- 🤖 MCP 服务优先策略
- 🧠 AI 语义去重
- 📦 多任务并行执行
- 🎨 Hexo 博客自动发布

---

## 版本说明

### [主版本号] - 重大架构变更
- 不兼容的 API 变更
- 重大功能重构

### [次版本号] - 功能增强
- 向后兼容的功能性新增
- 重要功能改进

### [修订号] - Bug 修复
- 向后兼容的问题修正
- 小的改进和优化
