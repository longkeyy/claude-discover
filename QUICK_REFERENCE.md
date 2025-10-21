# Quick Reference Card 🚀

Essential commands and workflows for daily use.

## 📦 Installation

```bash
# Install plugin
/plugin install https://github.com/longkeyy/claude-discover

# Verify installation
/mission show
```

## 🔨 Daily Commands

### Task Management

```bash
/mission                     # List all tasks
/mission add                 # Create new task
/mission enable <task-id>    # Enable task
/mission disable <task-id>   # Disable task
```

### Content Discovery

```bash
/discover                    # Run all enabled tasks (parallel)
/discover <task-id>          # Run specific task
/discover task1 task2        # Run multiple tasks
/discover --serial <task-id> # Debug mode (serial execution)
```

## 🚀 Publishing Workflow

```bash
# 1. Update version
make version-patch           # 1.0.0 → 1.0.1

# 2. Update changelog
vim .claude-plugin/CHANGELOG.md

# 3. Commit and publish
git add . && git commit -m "chore: release v1.0.1"
make publish
```

## 📁 Key Locations

| Path | Purpose |
|------|---------|
| `config/tasks/` | Task configurations (*.md) |
| `config/keywords/` | Keyword files (*.json) |
| `posts/{task-id}/` | Published content (JSON) |
| `temp/sessions/` | Session logs |

## 🔍 Troubleshooting

### No content discovered?
```bash
# Check task status
/mission show

# Run in debug mode
/discover --serial <task-id>

# Check logs
cat temp/sessions/{task-id}/{session-id}/session.log
```

### Publishing failed?
```bash
# Verify environment variables
cat .env

# Test Hexo path
ls $HEXO_PATH/source/_posts

# Test Telegram
curl -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe"
```

## 📚 Documentation

- **Full Guide**: [.claude-plugin/README.md]
- **中文文档**: [.claude-plugin/README_zh-CN.md]
- **Publishing**: [.claude-plugin/PUBLISHING.md]
- **Doc Map**: [.github/DOCUMENTATION_MAP.md]

## 💡 Pro Tips

```bash
# Parallel is 3-4x faster (default)
/discover task1 task2 task3

# Use serial for debugging
/discover --serial problematic-task

# Test before publishing
make test
```

---

**Need help?** Start with [.claude-plugin/README.md] for complete documentation.
