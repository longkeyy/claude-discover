# Content Discovery Plugin

> AI 驱动的内容发现框架，自动从 ArXiv、GitHub、HuggingFace 等平台发现、分析和发布优质内容。

## 📖 目录

- [这是什么](#这是什么)
- [能做什么](#能做什么)
- [如何安装](#如何安装)
- [快速开始](#快速开始)
- [详细使用](#详细使用)
- [进阶配置](#进阶配置)
- [常见问题](#常见问题)

---

## 这是什么

Content Discovery 是一个 Claude Code 插件，可以帮你：

**自动化内容发现工作流**
```
配置任务 → AI 搜索内容 → 智能去重 → 质量评估 → 多渠道发布
```

**适用场景**
- 📚 **学术研究者**：跟踪 ArXiv 最新论文
- 💻 **开源开发者**：发现优质 GitHub 项目
- 🤖 **AI 工程师**：关注 HuggingFace 新模型
- ✍️ **技术博主**：聚合多源优质内容

---

## 能做什么

### ✨ 核心功能

#### 1. 智能发现
- 🔍 自动搜索多个数据源（ArXiv、GitHub、HuggingFace）
- 🎯 基于关键词和过滤规则精准筛选
- 🚀 MCP 服务优先（更快、更准确）

#### 2. AI 分析
- 🧠 **语义去重**：理解内容含义而非简单 URL 匹配
- ⭐ **质量评估**：AI 自动评分相关性和新颖性
- 🔄 **关键词优化**：从发现的内容中学习新关键词

#### 3. 自动发布
- 📝 生成 Hexo 博客文章（Markdown）
- 📱 发布到 Telegram 频道
- 💬 发布到 Discord 服务器
- 💾 保存 JSON 记录便于管理

#### 4. 任务管理
- 📦 一个项目管理多个独立任务
- ⚙️ 每个任务独立配置（数据源、规则、渠道）
- ⚡ 支持并行执行多个任务

---

## 如何安装

### 方式一：从 Marketplace 安装（推荐）

```bash
/plugin install content-discovery
```

> 当 Claude Code Marketplace 上线后可用

### 方式二：从 GitHub 安装

```bash
/plugin install https://github.com/longkeyy/claude-discover/releases/latest/download/content-discovery.zip
```

### 方式三：从本地安装（开发/测试）

```bash
# 1. 克隆项目
git clone https://github.com/longkeyy/claude-discover.git

# 2. 安装 plugin
/plugin install ./claude-discover/.claude-plugin
```

### 可选：安装 MCP 服务（推荐）

安装这些 MCP 服务可获得更好的搜索效果：

```bash
# ArXiv 论文搜索
mcp install mcp__arxiv

# GitHub 项目搜索  
mcp install mcp__github

# HuggingFace 模型/数据集搜索
mcp install mcp__huggingface
```

---

## 快速开始

### 🎯 5 分钟上手

#### Step 1: 创建第一个任务

```bash
/mission add
```

跟随交互式向导配置：
1. **任务 ID**：如 `my-papers`
2. **任务类型**：选择 `paper` / `project` / `model` / `dataset`
3. **数据源**：选择 ArXiv / GitHub / HuggingFace
4. **关键词**：输入感兴趣的主题
5. **发布渠道**：选择 Hexo / Telegram / Discord

#### Step 2: 执行发现

```bash
/discover my-papers
```

AI 将自动：
- ✅ 搜索相关内容
- ✅ 过滤重复和低质量内容
- ✅ 生成摘要和发布
- ✅ 保存记录

#### Step 3: 查看结果

```bash
# 查看任务状态
/mission show

# 查看发布记录
ls posts/my-papers/

# 如果配置了 Hexo，查看博客
cd $HEXO_PATH && hexo server
```

### 📋 示例：跟踪 Prompt Engineering 论文

```bash
# 1. 创建任务
/mission add

# 配置：
#   - Task ID: prompt-papers
#   - Type: paper
#   - Source: ArXiv
#   - Keywords: "prompt engineering", "chain-of-thought", "in-context learning"
#   - Filters: cs.AI, cs.CL categories, last 1 year
#   - Publish: Hexo blog

# 2. 执行发现
/discover prompt-papers

# 3. 结果示例
# ✅ 找到 50 篇论文
# ✅ 过滤 15 篇重复
# ✅ 过滤 15 篇低质量
# ✅ 发布 20 篇高质量论文
# 💡 发现 5 个新关键词
```

---

## 详细使用

### 命令参考

#### `/mission` - 任务管理

```bash
# 查看所有任务
/mission show

# 创建新任务（交互式）
/mission add

# 启用/禁用任务
/mission enable <task-id>
/mission disable <task-id>

# 更新任务配置
/mission update <task-id>

# 删除任务（归档）
/mission delete <task-id>
```

#### `/discover` - 执行发现

```bash
# 执行所有启用的任务
/discover
/discover all

# 执行指定任务
/discover <task-id>

# 执行多个任务（并行，默认）
/discover task1 task2 task3

# 串行执行（调试用）
/discover --serial task1 task2
```

### 任务配置详解

任务配置文件位于 `config/tasks/{task-id}.md`，采用 Markdown + YAML 格式：

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
**Keywords file**: `config/keywords/prompt-papers.json`

初始关键词：
- "prompt engineering"
- "chain-of-thought"
- "in-context learning"
- "few-shot learning"

## 🔍 Filter Rules
```yaml
arxiv:
  time_range: "1 year"
  categories: [cs.AI, cs.CL, cs.LG]
  author_email_domains:
    - google.com
    - openai.com
    - anthropic.com
  min_citations: 10
```

## 📤 Publishing
```yaml
hexo:
  blog_path: ${env:HEXO_PATH}
  post_dir: source/_posts/prompt-engineering
  auto_generate: true
  
telegram:
  enabled: true
  channel_id: ${env:TELEGRAM_CHANNEL_ID}
  
discord:
  enabled: false
```
\`\`\`

### 工作流程图

```
/discover my-task

    ↓
┌─────────────────────────────┐
│ 1. 检测 MCP 服务             │
│    ✅ mcp__arxiv 可用        │
│    ❌ mcp__github 不可用     │
│    → 使用 WebSearch fallback│
├─────────────────────────────┤
│ 2. 搜索内容                  │
│    • 应用关键词              │
│    • 应用过滤规则            │
│    • 找到 50 篇论文          │
├─────────────────────────────┤
│ 3. AI 语义去重               │
│    • 对比已发布内容          │
│    • 理解内容语义            │
│    • 过滤 15 篇重复          │
│    • 剩余 35 篇              │
├─────────────────────────────┤
│ 4. 质量评估                  │
│    • AI 评分相关性           │
│    • AI 评分新颖性           │
│    • 过滤低分内容            │
│    • 剩余 20 篇高质量        │
├─────────────────────────────┤
│ 5. 图片提取（可选）          │
│    • 下载论文封面            │
│    • 提取架构图              │
├─────────────────────────────┤
│ 6. 多渠道发布                │
│    • 生成 Hexo Markdown     │
│    • 发布到 Telegram        │
│    • 保存 JSON 记录          │
├─────────────────────────────┤
│ 7. 关键词优化                │
│    • 从内容中发现新关键词    │
│    • 更新 keywords.json     │
└─────────────────────────────┘
    ↓
✅ 发布 20 篇论文
💡 发现 5 个新关键词
```

---

## 进阶配置

### 环境变量配置

复制 `.env.example` 到项目根目录的 `.env`：

```bash
# Hexo 博客路径（可选）
HEXO_PATH=/path/to/your/hexo/blog

# Telegram 发布（可选）
TELEGRAM_BOT_TOKEN=123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
TELEGRAM_CHANNEL_ID=@your_channel

# Discord 发布（可选）
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/123456789/abcdefg
```

### 过滤规则示例

#### ArXiv 论文过滤

```yaml
arxiv:
  time_range: "6 months"           # 时间范围
  categories: [cs.AI, cs.CL]       # 分类限制
  author_email_domains:            # 作者机构
    - google.com
    - openai.com
  min_citations: 10                # 最小引用数
  exclude_keywords:                # 排除关键词
    - "survey"
    - "review"
```

#### GitHub 项目过滤

```yaml
github:
  time_range: "3 months"
  min_stars: 100                   # 最小 star 数
  languages: [Go, Rust, Python]    # 编程语言
  topics: [ai, machine-learning]   # 主题标签
  exclude_archived: true           # 排除归档项目
```

#### HuggingFace 模型过滤

```yaml
huggingface:
  time_range: "1 month"
  model_types: [text-generation]   # 模型类型
  min_downloads: 1000              # 最小下载量
  min_likes: 50                    # 最小点赞数
  tags: [llm, transformers]        # 标签
```

### 发布渠道配置

#### Hexo 博客

```yaml
hexo:
  blog_path: ${env:HEXO_PATH}
  post_dir: source/_posts/ai-research    # 文章目录
  auto_generate: true                     # 自动生成
  template: custom                        # 使用自定义模板
  tags: [AI, Research, Papers]           # 默认标签
  categories: [学术论文]                  # 默认分类
```

#### Telegram

```yaml
telegram:
  enabled: true
  bot_token: ${env:TELEGRAM_BOT_TOKEN}
  channel_id: ${env:TELEGRAM_CHANNEL_ID}
  format: markdown                        # 消息格式
  preview_links: true                     # 预览链接
```

#### Discord

```yaml
discord:
  enabled: true
  webhook_url: ${env:DISCORD_WEBHOOK_URL}
  username: "Content Discovery Bot"
  avatar_url: "https://example.com/avatar.png"
  color: 0x3498db                        # 嵌入颜色
```

---

## 常见问题

### 安装和配置

**Q: 如何验证 plugin 是否安装成功？**

```bash
# 运行任何命令，如果能响应说明安装成功
/mission show
```

**Q: MCP 服务是必需的吗？**

不是必需的，但**强烈推荐**：
- ✅ 有 MCP：结构化数据，更快更准确
- ⚠️ 无 MCP：自动使用 WebSearch（较慢，可能不准确）

**Q: 如何配置 Hexo 路径？**

在项目根目录创建 `.env` 文件：
```bash
HEXO_PATH=/Users/username/my-blog
```

### 使用问题

**Q: 为什么没有发现任何内容？**

检查以下几点：
1. 关键词是否太具体？尝试更通用的关键词
2. 过滤规则是否太严格？放宽时间范围或其他限制
3. 数据源是否可用？检查 MCP 服务或网络连接

**Q: 如何避免发现重复内容？**

Plugin 自带语义去重功能：
- ✅ AI 理解内容含义，而非简单 URL 匹配
- ✅ 对比 `posts/{task-id}/` 中的所有已发布内容
- ✅ 相似度超过阈值的内容会被过滤

**Q: 如何调整内容质量标准？**

在任务配置中添加评估规则：
```yaml
evaluation:
  min_relevance_score: 0.7    # 最低相关性分数 (0-1)
  min_novelty_score: 0.6      # 最低新颖性分数 (0-1)
  require_abstract: true      # 必须有摘要
```

**Q: 能同时运行多个任务吗？**

可以，有两种方式：
```bash
# 并行执行（默认，更快）
/discover task1 task2 task3

# 串行执行（调试用，更安全）
/discover --serial task1 task2 task3
```

### 技术问题

**Q: 发布到 Hexo 失败？**

检查：
1. `HEXO_PATH` 是否正确？
2. Hexo 目录权限是否正确？
3. `source/_posts/` 目录是否存在？

**Q: 如何查看详细日志？**

运行任务时会在 `posts/{task-id}/` 目录下生成 JSON 记录，包含详细元数据。

**Q: 如何手动编辑任务配置？**

直接编辑配置文件：
```bash
vim config/tasks/{task-id}.md
```

修改后无需重启，下次执行 `/discover` 时会自动读取。

---

## 📚 扩展阅读

### 项目文档
- [项目主页](https://github.com/longkeyy/claude-discover)
- [架构设计](../ARCHITECTURE.md)
- [变更日志](CHANGELOG.md)

### 开发者文档
- [Plugin 结构说明](../PLUGIN_STRUCTURE.md)
- [发布指南](PUBLISHING.md)

### 外部资源
- [Claude Code 文档](https://docs.claude.com/en/docs/claude-code)
- [MCP 协议](https://modelcontextprotocol.io/)
- [Hexo 文档](https://hexo.io/docs/)

---

## 🤝 参与贡献

欢迎贡献！请：
1. Fork 项目
2. 创建 feature 分支
3. 提交 Pull Request

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

---

## 🙏 致谢

- [Claude Code](https://claude.ai/code) - AI agent 执行引擎
- [MCP](https://modelcontextprotocol.io/) - 模型上下文协议
- [Hexo](https://hexo.io/) - 静态博客生成器
- 开源社区的所有贡献者

---

## 📞 获取帮助

- **Issues**: [提交问题](https://github.com/longkeyy/claude-discover/issues)
- **Discussions**: [讨论区](https://github.com/longkeyy/claude-discover/discussions)
- **Documentation**: [完整文档](https://github.com/longkeyy/claude-discover)

---

**开始使用**: 运行 `/mission add` 创建你的第一个发现任务！🚀
