# Publishing Guide

完整的 Content Discovery Plugin 发布流程指南。

## 📋 发布前检查清单

### 1. 代码质量检查

```bash
# 运行测试
make test

# 检查所有必需文件
ls -la .claude-plugin/
```

确认以下文件存在且完整:
- [ ] `plugin.json` - Plugin 元数据
- [ ] `marketplace.json` - Marketplace 信息  
- [ ] `README.md` - 用户文档
- [ ] `INSTALL.md` - 安装指南
- [ ] `QUICKSTART.md` - 快速开始
- [ ] `CHANGELOG.md` - 变更日志
- [ ] `commands/` - 所有命令文件
- [ ] `skills/` - 所有技能文件
- [ ] `scripts/` - 所有脚本文件

### 2. 文档更新

#### 更新 CHANGELOG.md

```markdown
## [1.0.1] - 2025-10-20

### Added
- 新增功能描述

### Changed
- 变更描述

### Fixed
- Bug 修复描述
```

#### 更新版本号

```bash
# 自动更新版本号 (patch: 1.0.0 -> 1.0.1)
make version-patch

# 或手动选择版本类型
make version-minor  # 1.0.0 -> 1.1.0
make version-major  # 1.0.0 -> 2.0.0
```

这将自动更新:
- `.claude-plugin/plugin.json` 中的 `version`
- `.claude-plugin/marketplace.json` 中的 `plugins[0].version`

### 3. 本地测试

```bash
# 构建 plugin
make build

# 在 Claude Code 中测试
/plugin install /path/to/claude-discover/.claude-plugin

# 测试核心功能
/mission show
/discover --help
```

## 🚀 发布流程

### 方式一: 使用 Makefile (推荐)

```bash
# 1. 确保所有变更已提交
git status
git add .
git commit -m "chore: prepare release v1.0.1"

# 2. 运行测试
make test

# 3. 发布到 GitHub
make publish
```

`make publish` 将会:
1. 验证 plugin 配置
2. 创建 git tag (`v1.0.1`)
3. 推送 tag 到 GitHub
4. 触发 GitHub Actions 自动构建和发布

### 方式二: 手动发布

#### Step 1: 创建 Tag

```bash
# 获取当前版本
VERSION=$(jq -r '.version' .claude-plugin/plugin.json)

# 创建 tag
git tag -a "v${VERSION}" -m "Release v${VERSION}"

# 推送 tag
git push origin "v${VERSION}"
```

#### Step 2: GitHub Actions 自动构建

推送 tag 后，GitHub Actions 会自动:
1. 验证 `plugin.json`
2. 运行测试
3. 构建 plugin package
4. 创建 GitHub Release
5. 上传 `.zip` 文件和 checksum

#### Step 3: 验证 Release

访问 GitHub Releases 页面:
```
https://github.com/longkeyy/claude-discover/releases
```

确认:
- [ ] Release 已创建
- [ ] `content-discovery-{version}.zip` 已上传
- [ ] `content-discovery-{version}.zip.sha256` 已上传
- [ ] Release notes 正确

## 📦 用户安装方式

发布后,用户可以通过以下方式安装:

### 从 GitHub Release 安装

```bash
/plugin install https://github.com/longkeyy/claude-discover/releases/download/v1.0.1/content-discovery-1.0.1.zip
```

### 从本地路径安装

```bash
git clone https://github.com/longkeyy/claude-discover.git
cd claude-discover
/plugin install .claude-plugin
```

### 从 Marketplace 安装 (未来)

```bash
/plugin install content-discovery
```

## 🔄 版本管理策略

遵循 [Semantic Versioning](https://semver.org/):

### MAJOR (x.0.0)
重大变更,不向后兼容:
- 移除或重命名 commands/skills
- 改变核心 API 行为
- 需要用户重新配置

```bash
make version-major
```

### MINOR (1.x.0)
新功能,向后兼容:
- 添加新 commands/skills
- 添加新配置选项
- 增强现有功能

```bash
make version-minor
```

### PATCH (1.0.x)
Bug 修复,向后兼容:
- 修复 bug
- 文档更新
- 性能优化

```bash
make version-patch
```

## 📝 Release Notes 模板

在创建 release 时,使用以下模板:

```markdown
## Content Discovery Plugin v1.0.1

### ✨ What's New
- 新功能描述

### 🐛 Bug Fixes
- Bug 修复描述

### 📚 Documentation
- 文档更新描述

### 🔧 Internal Changes
- 内部优化描述

### 📦 Installation

\`\`\`bash
# From GitHub Release
/plugin install https://github.com/longkeyy/claude-discover/releases/download/v1.0.1/content-discovery-1.0.1.zip

# From source
git clone https://github.com/longkeyy/claude-discover.git
cd claude-discover
/plugin install .claude-plugin
\`\`\`

### 📖 Documentation
- [README](.claude-plugin/README.md)
- [Quick Start](.claude-plugin/QUICKSTART.md)
- [Installation Guide](.claude-plugin/INSTALL.md)
- [Architecture](ARCHITECTURE.md)

### 🙏 Contributors
Thank you to all contributors!
```

## 🛠️ 常见问题

### Q: GitHub Actions 构建失败怎么办?

1. 查看 Actions 日志:
   ```
   https://github.com/longkeyy/claude-discover/actions
   ```

2. 常见问题:
   - `plugin.json` 中的版本号与 tag 不匹配
   - JSON 格式错误
   - 文件权限问题

3. 修复后重新发布:
   ```bash
   # 删除错误的 tag
   git tag -d v1.0.1
   git push origin :refs/tags/v1.0.1
   
   # 修复问题后重新发布
   make publish
   ```

### Q: 如何发布 pre-release 版本?

```bash
# 创建 pre-release tag
git tag -a v1.1.0-beta.1 -m "Pre-release v1.1.0-beta.1"
git push origin v1.1.0-beta.1
```

然后在 GitHub Release 页面勾选 "This is a pre-release"。

### Q: 如何撤回已发布的版本?

```bash
# 1. 删除 GitHub Release (通过网页操作)

# 2. 删除 tag
git tag -d v1.0.1
git push origin :refs/tags/v1.0.1
```

⚠️ **警告**: 撤回版本会影响已安装的用户,谨慎操作!

## 📊 发布检查脚本

创建 `.github/workflows/release-checklist.yml`:

```yaml
name: Release Checklist

on:
  pull_request:
    branches: [main]

jobs:
  checklist:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Check CHANGELOG
        run: |
          if ! grep -q "## \[$(jq -r '.version' .claude-plugin/plugin.json)\]" .claude-plugin/CHANGELOG.md; then
            echo "❌ CHANGELOG.md not updated for version $(jq -r '.version' .claude-plugin/plugin.json)"
            exit 1
          fi
      
      - name: Validate JSON
        run: |
          jq empty .claude-plugin/plugin.json
          jq empty .claude-plugin/marketplace.json
      
      - name: Check required files
        run: ./scripts/test-plugin.sh
```

## 🎯 最佳实践

1. **每次发布前都运行完整测试**
   ```bash
   make test && make build
   ```

2. **保持 CHANGELOG 更新**
   - 每个 PR 都更新 CHANGELOG
   - 使用 [Keep a Changelog](https://keepachangelog.com/) 格式

3. **版本号与 tag 一致**
   - 使用 `make version-*` 自动更新
   - 或手动确保 `plugin.json` 和 tag 匹配

4. **发布前本地测试**
   - 在 Claude Code 中完整测试所有功能
   - 确保所有 commands 和 skills 正常工作

5. **及时回复 Issues**
   - 监控 GitHub Issues
   - 快速响应用户反馈

## 📅 发布计划示例

| 版本 | 发布日期 | 主要内容 | 类型 |
|------|---------|---------|------|
| 1.0.0 | 2025-10-20 | 初始发布 | Major |
| 1.0.1 | 2025-10-22 | Bug 修复 | Patch |
| 1.1.0 | 2025-11-01 | 新增 Discord 支持 | Minor |
| 2.0.0 | 2025-12-01 | 重构核心架构 | Major |

## 🔗 相关资源

- [GitHub Releases 文档](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Claude Code Plugin 文档](https://docs.claude.com/en/docs/claude-code/plugins)
