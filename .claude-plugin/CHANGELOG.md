# Changelog

All notable changes to the Content Discovery plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-01-22

### Changed
- **BREAKING**: Restructured plugin directories to comply with official Claude Code standards
  - Moved `commands/` from `.claude-plugin/` to plugin root
  - Moved `skills/` from `.claude-plugin/` to plugin root
  - Moved `hooks/` from `.claude-plugin/` to plugin root
  - Updated all script path references to `.claude-plugin/scripts/`
  - Synced `.claude/` local development configuration

### Migration Guide
If you have the plugin installed:
1. Uninstall old version: `/plugin uninstall content-discovery`
2. Install new version: `/plugin install https://github.com/longkeyy/claude-discover`
3. Existing task configurations and data remain compatible

### Technical Details
- Plugin structure now 100% compliant with [official standards](https://docs.claude.com/en/docs/claude-code/plugins)
- All validation checks pass
- No functional changes to commands or workflows

## [1.0.0] - 2025-01-20

### Added
- Initial plugin release
- **Commands**:
  - `/mission` - Complete task management system
    - `show` - Display all tasks and their status
    - `add` - Interactive task creation with guided configuration
    - `update` - Update existing task configurations
    - `enable` - Enable disabled tasks
    - `disable` - Temporarily disable tasks
    - `delete` - Archive and remove tasks
  - `/discover` - Execute content discovery
    - Support for single task execution
    - Support for multiple task execution
    - Parallel execution mode (default, faster)
    - Serial execution mode (for debugging)
    - Auto-execution of all enabled tasks

- **Skills**:
  - `content-discovery` - Core discovery workflow
    - MCP-first data source detection
    - Semantic AI deduplication
    - Quality assessment and scoring
    - Multi-language summary generation (Chinese primary)
    - Image extraction and downloading
    - Multi-channel publishing (Hexo, Telegram, Discord)
    - Automatic keyword optimization

- **Features**:
  - AI-powered semantic deduplication (not just URL matching)
  - MCP service auto-detection with WebSearch fallback
  - Support for multiple data sources:
    - ArXiv papers (via `mcp__arxiv` or WebSearch)
    - GitHub repositories (via `mcp__github` or WebSearch)
    - HuggingFace models/datasets (via `mcp__huggingface` or WebSearch)
  - Flexible filter rules (time range, categories, stars, etc.)
  - Multi-channel publishing:
    - Hexo blog generation
    - Telegram channel posting
    - Discord webhook posting
  - Automatic keyword learning and optimization
  - Session-based execution tracking
  - Comprehensive error handling and logging

- **Configuration**:
  - Markdown-based task configuration
  - JSON keyword management
  - Environment variable support
  - YAML filter rules

- **Scripts**:
  - Task management utilities (`scripts/mission/`)
  - Discovery utilities (`scripts/discover/`)
  - Image processing helpers
  - Index maintenance

- **Documentation**:
  - Comprehensive README
  - Installation guide
  - Architecture documentation
  - Usage examples and tutorials

### Technical Details
- Plugin architecture following Claude Code best practices
- Command + Skill pattern for clean separation of concerns
- Bash scripts for system integration
- Support for parallel and serial execution modes
- Automatic session management and cleanup
- Structured metadata tracking

### Dependencies
- **Required**: Claude Code CLI >= 1.0.0
- **Recommended**:
  - `mcp__arxiv` - For better ArXiv search
  - `mcp__github` - For better GitHub search
  - `mcp__huggingface` - For better HuggingFace search
- **Optional**:
  - Hexo - For blog publishing
  - Telegram Bot API - For Telegram publishing
  - Discord Webhooks - For Discord publishing

## [Unreleased]

### Planned Features
- [ ] RSS feed support for additional data sources
- [ ] Custom data source plugins
- [ ] Advanced analytics dashboard
- [ ] Scheduled automatic execution
- [ ] Email notifications
- [ ] Webhook-based publishing
- [ ] Content update detection
- [ ] Multi-language support (beyond Chinese/English)
- [ ] AI model fine-tuning from published content
- [ ] Collaborative task sharing

### Under Consideration
- GraphQL API for external integrations
- Web UI for task management
- Mobile notifications
- Integration with note-taking apps (Notion, Obsidian)
- Advanced AI features (trend prediction, topic clustering)

---

## Version History

- **1.0.0** - Initial plugin release with core functionality

---

**Note**: This plugin was converted from the standalone `claude-discover` project, unifying three independent discovery systems:
- `hf-discover` - HuggingFace model discovery
- `llm_datasets` - LLM dataset discovery
- `blog.zhiliyouxian.com` - Academic paper discovery

All original functionality has been preserved and enhanced in this unified plugin.
