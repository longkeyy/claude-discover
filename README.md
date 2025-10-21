# Claude Discover

基于 Claude Code 的 AI 驱动内容发现框架，自动从多个数据源发现、分析和发布优质内容。

> **🎉 现已作为 Claude Code Plugin 发布！** 使用 `/plugin install` 即可一键安装。
>
> 📖 **文档导航**: [Plugin 使用文档](.claude-plugin/README.md) | [文档地图](.github/DOCUMENTATION_MAP.md)

## 🎯 项目背景

在日常研发和研究工作中，我们需要持续跟踪多个领域的最新进展：
- 📚 **学术论文**：ArXiv 上的最新研究
- 💻 **开源项目**：GitHub 上的优质项目
- 🤖 **AI 模型**：HuggingFace 上的新模型和数据集
- 📰 **技术文章**：Medium、Reddit 等平台的技术讨论

传统方法需要手动搜索、筛选、整理，费时费力且容易遗漏。Claude Discover 通过 AI 自动化这个过程：
1. **自动发现**：根据配置的主题和关键词，自动搜索多个数据源
2. **智能分析**：AI 评估内容质量、新颖性和相关性
3. **去重过滤**：通过语义理解避免重复内容
4. **自动发布**：生成摘要并发布到 Hexo 博客、Telegram、Discord 等渠道
5. **持续优化**：从发现的内容中自动学习新关键词

**本项目统一了三个独立的发现系统：**
- `hf-discover` - HuggingFace 模型发现
- `llm_datasets` - LLM训练数据集发现
- `blog.zhiliyouxian.com` - 学术论文发现

现在，一个框架即可管理所有内容发现任务。

## ✨ 核心特性

### 🤖 AI-First 设计
- **语义去重**：AI 理解内容语义，而非简单 URL 匹配
- **智能评估**：自动评分内容质量、新颖性和相关性
- **关键词优化**：从发现的内容中自动学习新关键词
- **自然语言配置**：Markdown 格式，人类可读

### 🔌 MCP 服务优先
- 自动检测并使用 MCP 服务（`mcp__arxiv`, `mcp__github`, `mcp__huggingface`）
- 结构化数据，更快更准确
- 自动 fallback 到 WebSearch

### 📦 多任务管理
- 一个项目管理多个独立任务
- 每个任务独立配置：数据源、过滤规则、发布渠道
- 支持并行执行多个任务

### 🎯 灵活配置
- 支持复杂的过滤规则（star 数、时间范围、作者机构等）
- 多渠道发布（Hexo、Telegram、Discord）
- 环境变量管理敏感配置

### 🚀 极简架构
- 扁平化目录结构
- 语义化文件命名
- 最少脚本，AI 自动管理
- 零维护成本

## 🏗️ 架构概览

```
claude-discover/
├── blog/                      # Hexo博客目录（发布目标）
│   ├── source/_posts/        # Hexo文章目录
│   ├── source/images/        # 图片资源
│   └── themes/               # Hexo主题
├── config/
│   ├── tasks/                # 任务配置（Markdown）
│   │   └── prompt-papers.md # 示例：Prompt Engineering 论文发现
│   └── keywords/             # 关键词（JSON，自动更新）
│       └── prompt-papers.json
├── posts/{task-id}/          # 发布记录（语义化命名）
│   └── 2025-10-10_prompt-engineering_chain-of-thought.json
├── scripts/                  # 辅助脚本
│   ├── mission/             # 任务管理脚本
│   └── discover/            # 发现流程脚本
└── .claude/                 # Claude Code 配置
    ├── commands/            # 用户调用的命令
    │   ├── mission.md      # 任务管理入口
    │   └── discover.md     # 执行发现入口
    └── skills/              # AI 自主调用的技能
        └── content-discovery/  # 内容发现核心逻辑
            ├── skill.md       # Skill 定义和工作流
            └── helpers/       # 辅助脚本
```

### 架构说明

- **Commands（命令）**: 用户显式调用的工作流入口（`/mission`, `/discover`）
- **Skills（技能）**: AI 自主决定何时调用的模块化能力（`content-discovery`）
- **Scripts（脚本）**: 独立的 Bash 脚本，处理特定任务（环境检查、索引更新等）
- **Config（配置）**: 任务定义和关键词，驱动整个发现流程

## 🚀 快速开始

### 方式一：作为 Plugin 安装（推荐）

```bash
# 从 marketplace 安装（当发布后）
/plugin install content-discovery

# 或从本地路径安装
/plugin install /path/to/claude-discover/.claude-plugin

# 创建第一个任务
/mission add

# 执行发现
/discover
```

**详细的 Plugin 使用指南**: 参见 [.claude-plugin/README.md](.claude-plugin/README.md)

### 方式二：克隆项目直接使用

如果你想开发或自定义：

```bash
# 1. 克隆项目
git clone <repo-url> claude-discover
cd claude-discover

# 2. 配置环境

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑配置（至少配置 HEXO_PATH）
vim .env
```

### 3. 创建第一个任务

```bash
# 使用引导式配置（推荐）
/mission add

# 或手动创建
cp config/tasks/.template.md config/tasks/my-task.md
vim config/tasks/my-task.md
```

### 4. 执行发现

```bash
# 执行指定任务
/discover my-task

# 或执行所有启用的任务
/discover
```

### 5. 查看结果

```bash
# 查看发布的内容
ls posts/my-task/

# 查看 Hexo 博客
cd ${HEXO_PATH}
hexo server
```

**详细使用指南**：请参阅 [QUICKSTART.md](QUICKSTART.md)

## 📝 典型任务配置示例

```markdown
---
task_id: prompt-papers
task_type: paper
enabled: true
---

# Prompt Engineering Papers

## 📡 Data Sources
### Primary: ArXiv
- **Tool**: mcp__arxiv (fallback: WebSearch)

## 🎯 Topics & Keywords
**关键词配置**：`config/keywords/prompt-papers.json`

## 🔍 Filter Rules
\`\`\`yaml
arxiv:
  time_range: "1 year"
  categories: [cs.AI, cs.CL]
  author_email_domains:
    - google.com
    - openai.com
    - anthropic.com
\`\`\`

## 📤 Publishing
\`\`\`yaml
hexo:
  blog_path: ${env:HEXO_PATH}
  post_dir: source/_posts/prompt-engineering
  auto_generate: true
\`\`\`
```

## 🔄 工作流程

```
/discover prompt-papers

    ↓
┌─────────────────────────────┐
│ 1. 检测 MCP 服务             │
│    ✅ mcp__arxiv 可用        │
├─────────────────────────────┤
│ 2. 搜索论文                  │
│    • 应用关键词              │
│    • 应用过滤规则            │
│    • 找到 50 篇论文          │
├─────────────────────────────┤
│ 3. AI 语义去重               │
│    • 对比已发布内容          │
│    • 过滤 15 篇重复          │
│    • 剩余 35 篇              │
├─────────────────────────────┤
│ 4. 评估和分析                │
│    • AI 评分                 │
│    • 过滤低分内容            │
│    • 剩余 20 篇高质量        │
├─────────────────────────────┤
│ 5. 关键词优化                │
│    • 发现 5 个新关键词       │
│    • 更新 keywords.json     │
├─────────────────────────────┤
│ 6. 生成和发布                │
│    • 生成 Hexo Markdown     │
│    • 发布到博客              │
│    • 保存 JSON 记录          │
└─────────────────────────────┘
    ↓
✅ 发布 20 篇论文
💡 发现 5 个新关键词
```

## 🛠️ 命令参考

### /mission - 任务管理

```bash
/mission show                  # 列出所有任务
/mission add                   # 创建新任务（引导式）
/mission enable <task-id>      # 启用任务
/mission disable <task-id>     # 禁用任务
/mission delete <task-id>      # 删除任务（归档）
```

### /discover - 执行发现

```bash
/discover                      # 执行所有启用的任务
/discover <task-id>            # 执行指定任务
/discover <task-1> <task-2>    # 执行多个任务
/discover all                  # 执行所有启用的任务
```

## 🎨 核心设计理念

### 1. AI-First 架构
AI 不仅用于内容分析，更是整个系统的核心：
- **语义化命名**：文件名包含完整语义，AI 直接理解
- **语义去重**：AI 理解内容含义，避免简单 URL 匹配
- **Skills 驱动**：复杂逻辑封装在 Skills 中，AI 自主决定何时调用
- **自然语言配置**：Markdown 配置文件，人类和 AI 都易读

**Commands vs Skills**：
- **Commands**: 用户主动调用的工作流入口（如 `/mission`, `/discover`）
  - 处理参数解析和前置检查
  - 准备执行环境
  - 触发 Skills 执行

- **Skills**: AI 自主调用的模块化能力（如 `content-discovery`）
  - 包含完整的业务逻辑
  - 可在不同上下文中复用
  - AI 根据任务描述自动识别并调用

### 2. MCP 优先策略
MCP (Model Context Protocol) 服务提供结构化数据：
- 自动检测可用 MCP 服务
- 优先使用 MCP，性能更好、数据更准确
- 无缝 fallback 到 WebSearch

### 3. 配置驱动设计
所有行为通过配置定义，无需修改代码：
- Markdown + YAML 配置文件
- 支持环境变量引用（`${env:VAR}`）
- 灵活的过滤规则和评估标准

### 4. 极简主义
最少的复杂度，最大的灵活性：
- 扁平化目录，无复杂层级
- 语义化文件名，无需索引文件
- 最少脚本，仅保留必要的发布脚本
- AI 自动管理，零维护成本

## 📦 依赖项

### 必需
- **Claude Code CLI**：AI agent 执行引擎

### 推荐
- **MCP 服务**：更好的数据质量
  - `mcp__arxiv` - ArXiv 论文
  - `mcp__github` - GitHub 项目
  - `mcp__huggingface` - HuggingFace 模型/数据集
- **Hexo**：静态博客生成器（如果发布到 Hexo）

### 可选
- **Telegram Bot**：发布到 Telegram 频道
- **Discord Webhook**：发布到 Discord 服务器

## 🎯 使用场景

### 学术研究者
```bash
# 跟踪最新的 AI 研究论文
/mission add  # 配置 ArXiv 数据源，关注 cs.AI, cs.CL
/discover     # 每天自动发现新论文
```

### 开源开发者
```bash
# 发现优质的 Go/Rust 项目
/mission add  # 配置 GitHub 数据源，筛选高 star 项目
/discover     # 定期发现新项目
```

### AI 工程师
```bash
# 跟踪最新的 LLM 模型和数据集
/mission add  # 配置 HuggingFace 数据源
/discover     # 自动发现新模型/数据集
```

### 技术博主
```bash
# 聚合多个来源的优质内容
/mission add arxiv-papers    # ArXiv 论文
/mission add github-projects # GitHub 项目
/mission add ml-models       # HuggingFace 模型
/discover all                # 一键发现所有来源
```

## 📚 文档

### 用户文档
- **[.claude-plugin/README.md](.claude-plugin/README.md)** - 📖 完整用户手册（安装、使用、配置、FAQ）
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - 🚀 快速参考卡片

### 开发者文档
- **[PLUGIN_STRUCTURE.md](PLUGIN_STRUCTURE.md)** - 🏗️ 目录结构与工作流
- **[.claude-plugin/PUBLISHING.md](.claude-plugin/PUBLISHING.md)** - 📦 发布指南
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - 🏛️ 架构设计
- **[SUMMARY.md](SUMMARY.md)** - ✨ Plugin 化改造总结

### 其他文档
- **[CHANGELOG.md](.claude-plugin/CHANGELOG.md)** - 📝 变更日志

## 🤝 参考项目

Claude Discover 统一了以下三个独立项目：

1. **hf-discover** - HuggingFace 模型发现系统
   - 发现优质 AI 模型和数据集
   - 评估模型质量和受欢迎度

2. **llm_datasets** - NSFW 数据集发现系统
   - 发现和分类数据集
   - 投票和质量评估

3. **blog.zhiliyouxian.com** - 学术论文发现系统
   - ArXiv 论文跟踪
   - 自动生成博客文章

现在，这三个系统的功能都可以通过 Claude Discover 实现，只需配置不同的任务。

## 📄 许可证

MIT License

## 🙏 致谢

- [Claude Code](https://claude.ai/code) - AI agent 执行引擎
- [MCP](https://modelcontextprotocol.io/) - 模型上下文协议
- [Hexo](https://hexo.io/) - 静态博客生成器
- 开源社区的所有贡献者

---

**立即开始**：查看 [QUICKSTART.md](QUICKSTART.md) 获取详细使用指南

**问题反馈**：[提交 Issue](../../issues)
