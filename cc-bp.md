# Claude Code 核心模块关系与最佳实践指南

## 一、核心概念关系总结

Claude Code 由五个核心模块组成，它们之间存在清晰的层次和协作关系：

### 模块对比速查



### 关键区别

**调用方式的本质区别**[1][2][3]：
- **Command（命令）**：用户主动触发（输入 `/command-name`），类似于函数调用
- **Skill（技能）**：模型自动发现并调用，类似于自动加载的工具库
- **Agent（子代理）**：拥有独立上下文的AI专家，适合复杂多步骤任务[4][5]
- **Hook（钩子）**：事件驱动，在特定生命周期点自动触发[6][7]
- **Plugin（插件）**：容器级概念，用于打包和分发以上所有模块[8][9]

### 架构关系图
## 二、场景选择决策指南



## 三、各模块最佳实践

### 3.1 Plugin（插件）最佳实践

#### 目录结构标准[8][9]
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json              # 必需：插件清单
├── commands/                     # 可选：自定义命令
│   ├── deploy.md
│   └── test.md
├── agents/                       # 可选：子代理定义
│   ├── code-reviewer.md
│   └── debugger.md
├── skills/                       # 可选：技能包
│   ├── pdf-processing/
│   │   └── SKILL.md
│   └── excel-analysis/
│       └── SKILL.md
├── hooks/                        # 可选：钩子脚本
│   ├── hooks.json
│   └── format_code.sh
├── .mcp.json                     # 可选：MCP服务器配置
├── scripts/                      # 可选：辅助脚本
├── README.md                     # 推荐：使用文档
└── LICENSE                       # 推荐：许可证

```

#### plugin.json 配置模板[9]
```json
{
  "name": "my-awesome-plugin",
  "version": "1.0.0",
  "description": "简洁的功能描述",
  "author": {
    "name": "Your Name",
    "email": "your@email.com"
  },
  "homepage": "https://github.com/yourorg/plugin",
  "license": "MIT",
  "keywords": ["testing", "deployment", "automation"]
}
```

#### 最佳实践建议[8][9]
1. **版本管理**：使用语义化版本（SemVer）
2. **文档完善**：README.md 应包含安装、配置和使用示例
3. **依赖声明**：在 plugin.json 中明确列出依赖
4. **渐进增强**：先实现核心功能，通过版本迭代增加高级特性
5. **测试验证**：使用本地 marketplace 测试再发布[9]

### 3.2 Skill（技能）最佳实践

#### 目录结构[1]
```
.claude/skills/                   # 项目技能
└── pdf-processing/
    ├── SKILL.md                  # 必需：技能定义
    ├── REFERENCE.md              # 可选：详细文档
    ├── examples.md               # 可选：使用示例
    ├── scripts/
    │   ├── extract_text.py
    │   └── fill_form.py
    └── templates/
        └── form_template.pdf

~/.claude/skills/                 # 个人技能
└── my-workflow/
    └── SKILL.md
```

#### SKILL.md 文件模板[1]
```markdown
---
name: PDF Processing
description: Extract text, fill forms, merge PDFs. Use when working with PDF files, forms, or document extraction. Requires pypdf and pdfplumber packages.
allowed-tools: Read, Bash, Write
---

# PDF Processing Skill

## 快速开始

提取PDF文本：

```
import pdfplumber
with pdfplumber.open("doc.pdf") as pdf:
    text = pdf.pages.extract_text()
```

## 高级功能

详细API参考请查看 [REFERENCE.md](REFERENCE.md)

表单填充功能请查看 [examples.md](examples.md)

## 依赖要求

```
pip install pypdf pdfplumber
```

## 使用示例

1. 提取文本：`python scripts/extract_text.py input.pdf`
2. 填充表单：`python scripts/fill_form.py template.pdf data.json`
```

#### 最佳实践[1][10]
1. **描述精准**：在 `description` 中明确说明使用场景和触发关键词[1]
2. **渐进式加载**：主文档简洁，详细内容放入引用文件（如 REFERENCE.md）[1]
3. **工具限制**：使用 `allowed-tools` 限制只读技能的权限[1]
4. **依赖管理**：在描述中列出 Python/Node 依赖，让 Claude 自动安装[1]
5. **保持专注**：一个 Skill 只做一件事，不要设计通用技能[1]

### 3.3 Command（命令）最佳实践

#### 目录结构[11][12]
```
.claude/commands/                 # 项目命令
├── deploy.md
├── test.md
├── frontend/
│   ├── component.md
│   └── style-check.md
└── backend/
    ├── api-test.md
    └── db-migrate.md

~/.claude/commands/               # 个人命令
├── commit.md
└── security-review.md
```

#### 命令文件模板[13]

**基础命令**（deploy.md）：
```markdown
---
description: Deploy application to staging environment
---

# Deployment Command

1. Run tests: `npm test`
2. Build production bundle: `npm run build`
3. Deploy to staging: `./scripts/deploy.sh staging`
4. Run smoke tests
5. Report deployment status
```

**带参数的命令**（fix-issue.md）：
```markdown
---
argument-hint: [issue-number] [priority]
description: Fix a GitHub issue with specified priority
allowed-tools: Read, Edit, Bash, Grep
---

# Fix Issue #$1 (Priority: $2)

1. Fetch issue details: `gh issue view $1`
2. Analyze the problem
3. Implement fix
4. Create tests
5. Run test suite
6. Update issue with progress
```

**包含文件引用的命令**（review-config.md）：
```markdown
---
description: Review configuration files for security issues
---

# Configuration Review

## Files to Review
- Package config: @package.json
- TypeScript config: @tsconfig.json
- Environment: @.env

## Checklist
- [ ] No exposed secrets
- [ ] Dependencies up to date
- [ ] Proper security headers
```

#### 最佳实践[11][12][14]
1. **命名规范**：使用 kebab-case（短横线命名），如 `deploy-staging.md`
2. **参数传递**：使用 `$ARGUMENTS`（全部参数）或 `$1, $2...`（位置参数）
3. **目录组织**：相关命令放在子目录中（如 frontend/, backend/）
4. **CLAUDE.md 集成**：在项目的 CLAUDE.md 中引用命令[15][16]

### 3.4 Agent（子代理）最佳实践

#### 目录结构[4][5]
```
.claude/agents/                   # 项目级Agent
├── code-reviewer.md
├── debugger.md
└── data-scientist.md

~/.claude/agents/                 # 用户级Agent
└── security-auditor.md
```

#### Agent 配置模板[4][5]

**代码审查员**（code-reviewer.md）：
```markdown
---
name: code-reviewer
description: Expert code review specialist. Proactively reviews code for quality, security, and maintainability. Use immediately after writing or modifying code.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a senior code reviewer ensuring high standards of code quality and security.

## Invocation Protocol
When invoked:
1. Run `git diff` to see recent changes
2. Focus on modified files
3. Begin review immediately without asking

## Review Checklist
- Code is simple and readable
- Functions and variables are well-named
- No duplicated code
- Proper error handling
- No exposed secrets or API keys
- Input validation implemented
- Good test coverage
- Performance considerations addressed

## Output Format
Provide feedback organized by priority:
- **Critical Issues** (must fix immediately)
- **Warnings** (should address)
- **Suggestions** (consider improving)

Include specific code examples for fixes.
```

**调试专家**（debugger.md）：
```markdown
---
name: debugger
description: Debugging specialist for errors, test failures, and unexpected behavior. Use PROACTIVELY when encountering any issues.
tools: Read, Edit, Bash, Grep, Glob
model: sonnet
---

You are an expert debugger specializing in root cause analysis.

## Workflow
1. Capture error message and stack trace
2. Identify reproduction steps
3. Isolate the failure location
4. Form hypothesis
5. Add strategic debug logging
6. Implement minimal fix
7. Verify solution works

## For Each Issue Provide
- Root cause explanation
- Evidence supporting diagnosis
- Specific code fix
- Testing approach
- Prevention recommendations

Focus on fixing underlying issues, not symptoms.
```

#### 最佳实践[17][5]
1. **单一职责**：每个 Agent 只负责一个专业领域[17]
2. **工具权限最小化**：只授予必要的工具权限[5]
3. **主动触发词**：在 description 中使用 "PROACTIVELY" 或 "MUST BE USED" 提高触发率[5]
4. **详细提示词**：system prompt 应包含具体流程、检查清单和输出格式[5]
5. **模型选择**：复杂任务用 `opus`，一般任务用 `sonnet`，简单任务用 `haiku`[5]

### 3.5 Hook（钩子）最佳实践

#### 配置位置[6][7]
```
.claude/settings.json             # 项目级配置
~/.claude/settings.json           # 用户级配置
.claude/hooks/                    # 钩子脚本存放目录
```

#### 8种钩子事件[6][7]

| 事件类型 | 触发时机 | 典型用途 | 可否阻止执行 |
|---------|---------|---------|------------|
| **UserPromptSubmit** | 用户提交提示词前 | 添加上下文、验证输入 | ✓ |
| **PreToolUse** | 工具执行前 | 安全检查、权限验证 | ✓ |
| **PostToolUse** | 工具执行后 | 自动格式化、运行测试 | ✗ |
| **Notification** | 发送通知时 | 桌面提醒、日志记录 | ✗ |
| **Stop** | 主对话结束时 | 生成总结、清理资源 | ✗ |
| **SubagentStop** | 子Agent完成时 | 状态通知、结果处理 | ✗ |
| **PreCompact** | 上下文压缩前 | 备份会话、保存状态 | ✗ |
| **SessionStart/End** | 会话开始/结束 | 环境初始化/清理 | ✗ |

#### settings.json 配置示例[6][7]

**自动代码格式化**（PostToolUse）：
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | { read file_path; if [[ \"$file_path\" =~ \\.ts$ ]]; then npx prettier --write \"$file_path\"; fi; }"
          }
        ]
      }
    ]
  }
}
```

**阻止危险命令**（PreToolUse）：
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 -c \"import json, sys; data=json.load(sys.stdin); cmd=data.get('tool_input',{}).get('command',''); sys.exit(2 if 'rm -rf' in cmd or 'sudo' in cmd else 0)\""
          }
        ]
      }
    ]
  }
}
```

**桌面通知**（Notification）：
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.message' | xargs -I {} notify-send 'Claude Code' '{}'"
          }
        ]
      }
    ]
  }
}
```

**文件保护**（PreToolUse）：
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/protect_sensitive.py"
          }
        ]
      }
    ]
  }
}
```

对应的脚本（`.claude/hooks/protect_sensitive.py`）：
```python
#!/usr/bin/env python3
import json
import sys

# 读取钩子输入
data = json.load(sys.stdin)
file_path = data.get('tool_input', {}).get('file_path', '')

# 敏感文件列表
sensitive_patterns = ['.env', 'secrets.', 'password', '.key', '.pem']

# 检查是否为敏感文件
if any(pattern in file_path.lower() for pattern in sensitive_patterns):
    print(f"⛔ Blocked: Cannot modify sensitive file: {file_path}")
    sys.exit(2)  # 退出码2：阻止工具执行

sys.exit(0)  # 退出码0：允许执行
```

#### 最佳实践[18][6][7]
1. **退出码控制**[18]：
   - `0`：允许继续执行
   - `1`：错误，但不阻止
   - `2`：阻止工具执行（仅限 PreToolUse）

2. **性能优化**：钩子应快速执行（<1秒），避免阻塞主流程[18]

3. **幂等性**：钩子可能被多次调用，应设计为幂等的[18]

4. **错误处理**：钩子脚本应捕获异常，避免中断整个流程[6]

5. **安全审查**：钩子拥有完整系统权限，安装前必须审查代码[6]

6. **测试验证**：使用 `claude --debug` 查看钩子执行日志[1]

### 3.6 CLAUDE.md 最佳实践

#### 文件位置与优先级[15][16]
```
project-root/
├── CLAUDE.md                     # 全局项目上下文
├── frontend/
│   └── CLAUDE.md                 # 前端特定上下文
└── backend/
    └── CLAUDE.md                 # 后端特定上下文
```

#### 推荐模板结构[15][16][19]
```markdown
# [项目名称] - Claude Code 配置

## 🚨 关键架构文档（优先阅读）
- 整体架构：/docs/ARCHITECTURE.md
- 数据库设计：/docs/DATABASE_SCHEMA.md
- API规范：/docs/API_SPEC.md
- 认证流程：/docs/AUTH_FLOW.md ⚠️ 必读

## 项目概述
[简要说明项目目的、技术栈、主要功能]

## 开发规范

### 代码风格
- 使用 TypeScript，禁用 any 类型
- 使用函数式组件 + Hooks（React）
- 文件命名：kebab-case
- 变量命名：camelCase
- 常量命名：UPPER_SNAKE_CASE

### 提交规范
- 格式：`type(scope): description`
- 类型：feat, fix, docs, refactor, test, chore
- 使用 `/commit` 命令生成提交信息

## 常用命令

### 开发
- 启动开发服务器：`npm run dev`
- 运行测试：`npm test`
- 代码检查：`npm run lint`

### 部署
- 使用命令：`/deploy staging` 或 `/deploy production`

### 代码审查
- 使用命令：`/review` 或 明确要求 "Use code-reviewer agent"

## 工作流关键词

当我说以下关键词时，请执行对应操作：
- **"提交改动"**：执行 `/commit` 命令
- **"审查代码"**：使用 code-reviewer agent
- **"修复测试"**：使用 debugger agent
- **"部署到测试环境"**：执行 `/deploy staging`

## 重要注意事项
- ⚠️ 禁止直接编辑 `package-lock.json`
- ⚠️ 所有数据库变更必须通过 migration
- ⚠️ API 变更需更新 `/docs/API_SPEC.md`
- ✅ 新功能必须包含单元测试

## 技术债务与已知问题
- TODO: 重构 auth 模块（见 /docs/AUTH_REFACTOR.md）
- BUG: 并发登录导致session冲突（见 issue #123）

## 参考资源
- 文档目录：/docs/
- 组件库：/src/components/README.md
- API手册：https://api.example.com/docs
```

#### 最佳实践[15][16]
1. **保持精简**：主 CLAUDE.md 控制在 500 行以内，详细内容使用文档引用[15]
2. **使用 emoji**：🚨 紧急、⚠️ 警告、✅ 完成、🆕 新增，提高可读性[15]
3. **动态维护**：每次创建重要文档时立即更新引用列表[15]
4. **分层设计**：根目录放通用规范，子目录放模块特定规范[16]
5. **避免冗余**：与 Skills/Commands 重复的内容应移到对应模块[10]

## 四、完整项目结构示例

```
my-awesome-project/
├── CLAUDE.md                     # 项目主配置
├── README.md
├── package.json
├── .gitignore
│
├── .claude/                      # Claude Code 配置目录
│   ├── settings.json             # 项目级设置（hooks配置）
│   ├── settings.local.json       # 本地覆盖（不提交git）
│   │
│   ├── commands/                 # 项目命令
│   │   ├── deploy.md
│   │   ├── test.md
│   │   ├── commit.md
│   │   └── frontend/
│   │       ├── component.md
│   │       └── style-check.md
│   │
│   ├── agents/                   # 项目子代理
│   │   ├── code-reviewer.md
│   │   ├── debugger.md
│   │   └── data-analyst.md
│   │
│   ├── skills/                   # 项目技能
│   │   ├── api-testing/
│   │   │   ├── SKILL.md
│   │   │   └── scripts/
│   │   └── db-migration/
│   │       └── SKILL.md
│   │
│   └── hooks/                    # 钩子脚本
│       ├── format_code.py
│       ├── protect_sensitive.py
│       └── run_tests.sh
│
├── docs/                         # 架构文档
│   ├── ARCHITECTURE.md
│   ├── DATABASE_SCHEMA.md
│   └── API_SPEC.md
│
└── src/                          # 源代码
    ├── frontend/
    │   └── CLAUDE.md             # 前端特定配置
    └── backend/
        └── CLAUDE.md             # 后端特定配置
```

## 五、工作流集成示例

### 场景1：团队协作项目配置

**步骤1：创建团队 Plugin**
```bash
# 创建插件目录
mkdir -p team-standards/.claude-plugin
cd team-standards

# 创建插件清单
cat > .claude-plugin/plugin.json << 'EOF'
{
  "name": "company-standards",
  "version": "1.0.0",
  "description": "Company-wide development standards and tools"
}
EOF

# 添加团队命令
mkdir commands
cat > commands/pr-review.md << 'EOF'
---
description: Create pull request with comprehensive review checklist
---

# PR Review Process

1. Run all tests: `npm test`
2. Check code coverage: `npm run coverage`
3. Run linter: `npm run lint`
4. Review security: Use security-reviewer agent
5. Create PR with template: `gh pr create --template`
EOF

# 添加团队 Agent
mkdir agents
cat > agents/security-reviewer.md << 'EOF'
---
name: security-reviewer
description: Security-focused code reviewer. Use for all PR reviews.
tools: Read, Grep, Glob
---

Security Review Checklist:
- SQL injection vulnerabilities
- XSS risks
- Authentication bypass
- Exposed credentials
- Insecure dependencies
EOF
```

**步骤2：团队成员安装**
```bash
# 在团队 git 仓库中
git clone https://github.com/company/plugins
cd my-project
/plugin marketplace add ../plugins
/plugin install company-standards@plugins
```

### 场景2：个人效率工作流

**个人全局配置**（`~/.claude/`）：
```bash
# 个人常用命令
mkdir -p ~/.claude/commands
cat > ~/.claude/commands/quick-commit.md << 'EOF'
---
description: Quick commit with auto-generated message
---
1. Check git status
2. Stage all changes
3. Generate commit message from diff
4. Commit with message
EOF

# 个人全局 Agent
mkdir -p ~/.claude/agents
cat > ~/.claude/agents/research-assistant.md << 'EOF'
---
name: research-assistant
description: Research technical topics and summarize findings
tools: Read, Bash, WebFetch
model: opus
---
Research Protocol:
1. Search multiple sources
2. Summarize key findings
3. Provide code examples
4. List references
EOF

# 全局自动格式化 Hook
cat > ~/.claude/settings.json << 'EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs prettier --write"
          }
        ]
      }
    ]
  }
}
EOF
```

## 六、常见问题与解决方案

### Q1: Skill 不被触发怎么办？[1]

**检查清单**：
1. **描述是否具体**：description 应包含明确的触发关键词
2. **文件路径正确**：确认在 `.claude/skills/skill-name/SKILL.md`
3. **YAML 语法正确**：使用 `cat SKILL.md | head -n 10` 检查
4. **重启 Claude Code**：修改后需要重启才能生效

**改进示例**：
```markdown
# ❌ 太模糊
description: Helps with documents

# ✅ 具体明确
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

### Q2: Agent 和 Skill 如何选择？[3]

**使用 Agent 的场景**：
- 需要多步推理和规划
- 需要独立上下文（避免污染主对话）
- 复杂任务（如完整的代码审查、调试流程）

**使用 Skill 的场景**：
- 单一明确的任务（如格式转换）
- 需要与主对话共享上下文
- 轻量级增强功能

### Q3: Hook 执行失败怎么调试？[6]

```bash
# 1. 启用调试模式
claude --debug

# 2. 检查钩子配置
cat ~/.claude/settings.json | jq '.hooks'

# 3. 手动测试钩子脚本
echo '{"tool_name":"Edit","tool_input":{"file_path":"test.ts"}}' | \
  .claude/hooks/format_code.py

# 4. 验证退出码
echo $?  # 0=成功, 1=错误, 2=阻止
```

### Q4: 如何管理多个项目的配置？[15][16]

**方案1：使用用户级配置 + 项目级覆盖**
- `~/.claude/`: 个人通用配置
- `.claude/`: 项目特定配置
- 优先级：项目 > 用户 > 默认

**方案2：创建配置模板**
```bash
# 创建模板
mkdir ~/claude-templates
cp -r ~/.claude ~/claude-templates/web-project
cp -r ~/.claude ~/claude-templates/data-project

# 新项目使用模板
cd new-project
cp -r ~/claude-templates/web-project/.claude .
```

## 七、进阶技巧

### 7.1 Skills 调用 Agents[20]

在 Skill 中可以建议使用特定 Agent：

```markdown
---
name: Complex Debug
description: Debug complex issues requiring deep analysis
---

# Complex Debugging

For this type of issue, I recommend using the debugger agent:

> Use the debugger subagent to analyze this error in detail.

The debugger agent has specialized tools and context for root cause analysis.
```

### 7.2 Command 参数化与条件逻辑[13]

```markdown
---
argument-hint: [environment] [service]
description: Deploy specific service to environment
---

# Deploy $1 to $2

**Environment**: $1 (dev/staging/production)  
**Service**: $2 (api/web/worker)

## Pre-flight Checks
!`./scripts/preflight-check.sh $1 $2`

## Deployment
```
if [ "$1" = "production" ]; then
  echo "⚠️ Production deployment requires approval"
  exit 2
fi
./deploy.sh --env=$1 --service=$2
```

## Post-deployment
- Run smoke tests
- Verify health endpoints
```

### 7.3 Hook 链式调用[7]

在 settings.json 中配置多个钩子顺序执行：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/1_format.sh"
          },
          {
            "type": "command",
            "command": ".claude/hooks/2_lint.sh"
          },
          {
            "type": "command",
            "command": ".claude/hooks/3_test.sh"
          }
        ]
      }
    ]
  }
}
```

### 7.4 动态上下文注入[6]

使用 SessionStart Hook 自动加载项目状态：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/load_context.sh"
          }
        ]
      }
    ]
  }
}
```

`load_context.sh`:
```bash
#!/bin/bash
echo "## Recent Git Activity"
git log --oneline -5

echo "## Open Issues"
gh issue list --limit 5

echo "## Modified Files"
git status --short
```

## 八、安全最佳实践

### 8.1 敏感信息保护[6]

**PreToolUse Hook 防护**：
```python
#!/usr/bin/env python3
import json, sys, re

data = json.load(sys.stdin)
tool_input = data.get('tool_input', {})

# 检查是否包含敏感模式
sensitive_patterns = [
    r'password\s*=',
    r'api[_-]?key\s*=',
    r'secret\s*=',
    r'token\s*=',
]

content = str(tool_input)
for pattern in sensitive_patterns:
    if re.search(pattern, content, re.IGNORECASE):
        print("⛔ Detected potential credential in tool input")
        sys.exit(2)

sys.exit(0)
```

### 8.2 命令白名单[6]

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 -c \"import json,sys;data=json.load(sys.stdin);cmd=data.get('tool_input',{}).get('command','');allowed=['ls','cat','grep','git'];sys.exit(0 if any(cmd.startswith(c) for c in allowed) else 2)\""
          }
        ]
      }
    ]
  }
}
```

### 8.3 审计日志[7]

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "jq -c '{timestamp: now, tool: .tool_name, input: .tool_input}' >> ~/.claude/audit.jsonl"
          }
        ]
      }
    ]
  }
}
```

## 九、总结

Claude Code 的五个核心模块形成了完整的扩展生态系统[21][8][2][9][6]：

1. **Plugin**：顶层容器，用于打包和分发完整工具集，适合团队协作
2. **Skill**：AI 自动发现的能力扩展，适合单一明确的任务增强
3. **Command**：用户主动触发的固定流程，适合重复性操作
4. **Agent**：独立上下文的专家人格，适合复杂多步骤任务
5. **Hook**：事件驱动的自动化，适合工作流集成

**关键设计原则**：
- 单一职责：每个模块专注一件事
- 渐进增强：从简单配置开始，逐步添加高级特性
- 安全优先：始终审查钩子和脚本的安全性
- 文档完善：清晰的描述和示例提高可维护性

通过合理组合这些模块，可以构建强大的 AI 辅助开发工作流，显著提升团队效率[22][23][24][25]。

来源
[1] Agent Skills - Claude Docs https://docs.claude.com/en/docs/claude-code/skills
[2] Claude Skills: Customize AI for your workflows - Anthropic https://www.anthropic.com/news/skills
[3] Claude Skills vs Subagent: What's the difference? - eesel AI https://www.eesel.ai/blog/skills-vs-subagent
[4] Custom Agents | ClaudeLog https://www.claudelog.com/mechanics/custom-agents/
[5] Subagents - Claude Docs https://docs.claude.com/en/docs/claude-code/sub-agents
[6] Get started with Claude Code hooks https://docs.claude.com/en/docs/claude-code/hooks-guide
[7] A complete guide to hooks in Claude Code: Automating ... - eesel AI https://www.eesel.ai/blog/hooks-in-claude-code
[8] Improving your coding workflow with Claude Code Plugins - Composio https://composio.dev/blog/claude-code-plugin
[9] Plugins - Claude Docs https://docs.claude.com/en/docs/claude-code/plugins
[10] Claude Code Skills Just Changed Everything About AI Assistants https://www.ai-supremacy.com/p/claude-code-skills-just-changed-everything-agents-anthropic
[11] Your complete guide to slash commands Claude Code - eesel AI https://www.eesel.ai/blog/slash-commands-claude-code
[12] Claude Code Slash Commands: Boost Your Productivity with ... https://alexop.dev/tils/claude-code-slash-commands-boost-productivity/
[13] Slash Commands in the SDK - Claude Docs https://docs.claude.com/en/docs/claude-code/sdk/sdk-slash-commands
[14] Claude Code AI best practices - Craft Better Software https://craftbettersoftware.com/p/claude-code-ai-best-practices
[15] Tip: Managing Large CLAUDE.md Files with Document References ... https://www.reddit.com/r/ClaudeAI/comments/1lr6occ/tip_managing_large_claudemd_files_with_document/
[16] My Claude Code Usage Best Practices and Recommendations https://nikiforovall.blog/productivity/2025/06/13/claude-code-rules.html
[17] Best practices for Claude Code subagents - PubNub https://www.pubnub.com/blog/best-practices-for-claude-code-sub-agents/
[18] Claude Code Hooks Guide — claude_agent_sdk v0.4.0 - HexDocs https://hexdocs.pm/claude_agent_sdk/hooks_guide.html
[19] The ULTIMATE AI Coding Guide for Developers (Claude Code) https://www.sabrina.dev/p/ultimate-ai-coding-guide-claude-code
[20] Better than MCPs? Claude Code's New Skills Feature - YouTube https://www.youtube.com/watch?v=v1y5EUSQ8WA
[21] Customize Claude Code with plugins - Anthropic https://www.anthropic.com/news/claude-code-plugins
[22] Claude Code Best Practices - Use Claude to Its Full Potential https://www.shuttle.dev/blog/2025/10/16/claude-code-best-practices
[23] My 7 essential Claude Code best practices for production-ready AI ... https://www.eesel.ai/blog/claude-code-best-practices
[24] Building Agents with Claude Code's SDK - PromptLayer Blog https://blog.promptlayer.com/building-agents-with-claude-codes-sdk/
[25] Building agents with the Claude Agent SDK - Anthropic https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk
[26] Claude Code: Best practices for agentic coding - Anthropic https://www.anthropic.com/engineering/claude-code-best-practices
[27] How I use Claude Code (+ my best tips) - Builder.io https://www.builder.io/blog/claude-code
[28] Subagents, Claude.MD and slash commands? : r/ClaudeCode https://www.reddit.com/r/ClaudeCode/comments/1o8t6xe/difference_between_skills_and_these_subagents/
[29] A Brief Guide to Setting Up Claude Code from Scratch - Reddit https://www.reddit.com/r/ClaudeAI/comments/1mx255o/a_brief_guide_to_setting_up_claude_code_from/
[30] How to Set Up Claude Code for WordPress Plugin Development https://kahunam.com/articles/wordpress/how-to-set-up-claude-code-for-wordpress-plugin-development/
[31] Cooking with Claude Code: The Complete Guide - Sid Bharath https://www.siddharthbharath.com/claude-code-the-complete-guide/
[32] Anthropic's Guide to Claude Code: Best Practices for Agentic Coding https://www.reddit.com/r/ClaudeAI/comments/1k5slll/anthropics_guide_to_claude_code_best_practices/
[33] Claude Code Plugins Just Changed My Workflow Forever - YouTube https://www.youtube.com/watch?v=-KusSduAP1A
[34] Claude Code Best Practices: A Newbie's Guide to Learning from the ... https://www.linkedin.com/pulse/claude-code-best-practices-newbies-guide-learning-from-rafael-knuth-l9zzf
[35] How to Build Comprehensive Project Rules with Claude Code https://www.nathanonn.com/how-to-build-comprehensive-project-rules-with-claude-code/
[36] anthropics/skills: Public repository for Skills - GitHub https://github.com/anthropics/skills
[37] Claude Skills are awesome, maybe a bigger deal than MCP https://simonwillison.net/2025/Oct/16/claude-skills/
[38] Full manual for writing your first Claude Code Agents - Reddit https://www.reddit.com/r/Anthropic/comments/1ma4epq/full_manual_for_writing_your_first_claude_code/
[39] What are your "best practices" for Claude Code? - Reddit https://www.reddit.com/r/ClaudeCode/comments/1nris9w/what_are_your_best_practices_for_claude_code/
[40] Claude Skills are awesome, maybe a bigger deal than MCP https://news.ycombinator.com/item?id=45619537
[41] Agent SDK overview - Claude Docs https://docs.claude.com/en/api/agent-sdk/overview
[42] Daniel San on X https://x.com/dani_avila7/status/1979349357636767986
[43] The Ultimate Claude Code Guide: Every Hidden Trick, Hack, and ... https://dev.to/holasoymalva/the-ultimate-claude-code-guide-every-hidden-trick-hack-and-power-feature-you-need-to-know-2l45
[44] disler/claude-code-hooks-mastery - GitHub https://github.com/disler/claude-code-hooks-mastery
[45] Claude Code can invoke your custom slash commands - Reddit https://www.reddit.com/r/ClaudeAI/comments/1noyvmq/claude_code_can_invoke_your_custom_slash_commands/
[46] How Claude Code Hooks Save Me HOURS Daily - YouTube https://www.youtube.com/watch?v=Q4gsvJvRjCU
[47] Slash Commands - Claude Code Tutorial #6 - YouTube https://www.youtube.com/watch?v=52KBhQqqHuc
[48] Automate Your AI Workflows with Claude Code Hooks | Butler's Log https://blog.gitbutler.com/automate-your-ai-workflows-with-claude-code-hooks
[49] Claude Code Tutorial: Build a YouTube Research Agent using ... https://creatoreconomy.so/p/claude-code-tutorial-build-a-youtube-research-agent-in-15-min
[50] Complete Guide: Creating Claude Code Hooks - Suite Insider https://suiteinsider.com/complete-guide-creating-claude-code-hooks/

