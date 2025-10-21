# Claude Discover Documentation Map

This document provides a comprehensive guide to all documentation in this repository.

## 📚 Documentation Structure

### For Users

#### Getting Started
1. **[.claude-plugin/README.md]** - **START HERE** ⭐
   - Complete user manual
   - Installation, usage, configuration
   - FAQ and troubleshooting
   - Primary documentation for all users

2. **[.claude-plugin/README_zh-CN.md]** - Chinese version
   - Complete Chinese translation
   - Same content as English README

#### Quick Reference
3. **[QUICK_REFERENCE.md]** - Quick reference card
   - Common commands
   - Publishing workflow
   - Troubleshooting guide
   - For experienced users

### For Developers

#### Development Guides
4. **[.claude-plugin/PUBLISHING.md]** - Publishing guide
   - Release process
   - Version management
   - GitHub Actions setup

5. **[Makefile]** - Build automation
   - Available commands
   - Testing and building
   - Version bumping

6. **[QUICK_REFERENCE.md]** - Quick reference card
   - Essential commands
   - Publishing workflow
   - Troubleshooting tips

## 📖 Documentation by Task

### "I want to install and use this plugin"
→ Read: [.claude-plugin/README.md]
→ Quick start section

### "I want to create a task"
→ Read: [.claude-plugin/README.md] - Task Configuration section
→ Examples: [.claude-plugin/examples/]

### "I want to publish to my blog"
→ Read: [.claude-plugin/README.md] - Publishing Configuration section
→ Example: [.claude-plugin/examples/.env.example]

### "I want to contribute code"
→ Read: [.claude-plugin/README.md] - Architecture section
→ Review: [Makefile]
→ Check: [.claude-plugin/PUBLISHING.md]

### "I want to release a new version"
→ Read: [.claude-plugin/PUBLISHING.md]
→ Use: `make version-patch && make publish`

## 🗑️ Archived Files

The following files have been **archived** to `.archive/docs/`:

**Initial Development** (historical reference):
- `COMPLIANCE_SUMMARY.md` - Initial compliance check
- `PLUGIN_COMPLIANCE_REPORT.md` - Structure validation
- `PLUGIN_CONVERSION_SUMMARY.md` - Migration process
- `DOCUMENTATION.md` - Old structure notes

**Recent Cleanup** (2025-01-22):
- `SUMMARY.md` - Plugin migration summary
- `PLUGIN_STRUCTURE.md` - Directory structure details (now in README)
- `PLUGIN_ENHANCEMENT_SUMMARY.md` - Enhancement work record
- `ARCHITECTURE.md` - Design details (now in plugin README)

These files are preserved for historical reference in `.archive/docs/`

## 📌 Documentation Maintenance

### When to Update

| File | Update When |
|------|-------------|
| `.claude-plugin/README.md` | Adding features, changing commands, updating config |
| `.claude-plugin/CHANGELOG.md` | Every release |
| `QUICK_REFERENCE.md` | Adding new essential commands |
| `.claude-plugin/PUBLISHING.md` | Changing release process |
| `README.md` | Major project changes or feature additions |

### Update Checklist

Before releasing a new version:
- [ ] Update `.claude-plugin/README.md` if user-facing changes
- [ ] Update `.claude-plugin/CHANGELOG.md` with all changes
- [ ] Update version in `.claude-plugin/plugin.json`
- [ ] Update examples if configuration schema changed
- [ ] Test documentation with `make test`

## 🔗 External Resources

- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Plugin Development Guide](https://docs.claude.com/en/docs/claude-code/plugins)
- [MCP Protocol](https://modelcontextprotocol.io/)

## 💡 Documentation Best Practices

1. **Single Source of Truth**: One comprehensive README
2. **User-First**: Write from user perspective
3. **Progressive Disclosure**: Start simple, add details gradually
4. **Examples Everywhere**: Show, don't just tell
5. **Keep Updated**: Documentation drift is technical debt

---

**Note**: This map itself is documentation about documentation. If you find it confusing, you're reading too deep - just start with [.claude-plugin/README.md]!
