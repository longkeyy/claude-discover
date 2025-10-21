---
# Task Configuration Example: GitHub Repositories
# Copy this to config/tasks/ and customize for your needs
# File name should be: {task-id}.md (lowercase, kebab-case)

name: "AI Tools & Libraries"
task_id: "ai-tools"
description: "Discover trending AI tools and libraries from GitHub"
enabled: true
---

# GitHub Repositories Discovery Task

## Data Sources

### GitHub (Primary)
- **Enabled**: true
- **Languages**: Python, TypeScript, Rust
- **Min Stars**: 100
- **Time Range**: last_30_days
- **Topics**: artificial-intelligence, machine-learning, llm

## Filtering Rules

```yaml
filters:
  minimum_stars: 100
  has_readme: true
  time_range: "last_30_days"

  languages:
    - Python
    - TypeScript
    - Rust
    - Go

  topics:
    - "artificial-intelligence"
    - "machine-learning"
    - "llm"
    - "claude"
    - "openai"
    - "huggingface"

  # Exclude certain patterns
  exclude_patterns:
    - "awesome-*"        # Skip awesome lists
    - "*-tutorial"       # Skip tutorials
    - "learn-*"          # Skip learning repos

  minimum_quality_score: 70
```

## Content Quality Standards

- **Language**: Chinese summaries required
- **Minimum Length**: 800 characters
- **Required Fields**:
  - github_url
  - title
  - description
  - readme_summary
  - stars
  - main_language

## Scoring Weights

```yaml
scoring_weights:
  stars: 0.3         # GitHub stars
  activity: 0.2      # Recent commits
  relevance: 0.3     # Match with keywords
  completeness: 0.2  # README, docs, examples
```

## Publishing Configuration

### Hexo Blog
```yaml
hexo:
  enabled: true
  post_dir: "source/_posts/tools"
  template: |
    ---
    title: {{ title }}
    date: {{ date }}
    categories: [tools]
    tags: {{ tags }}
    github_url: {{ github_url }}
    stars: {{ stars }}
    language: {{ language }}
    ---

    {{ summary }}

    ## Features
    {{ features }}

    ## Quick Start
    {{ quick_start }}

    ## Resources
    - GitHub: {{ github_url }}
    - Stars: {{ stars }} ⭐
    - Language: {{ language }}
```

### Telegram Channel
```yaml
telegram:
  enabled: true
  channel_id: "@your_channel"
  format: |
    🔧 **{{ title }}**

    {{ summary_short }}

    ⭐ Stars: {{ stars }}
    💻 Language: {{ language }}
    🔗 GitHub: {{ github_url }}
```

### Discord Webhook
```yaml
discord:
  enabled: false
```

## Image Extraction

```yaml
images:
  cover:
    enabled: true
    sources:
      - "README cover image"
      - "Social preview image"

  screenshots:
    enabled: true
    max_count: 3
    sources:
      - "README screenshots"
      - "docs/images/"

  diagrams:
    enabled: true
    max_count: 2
    sources:
      - "Architecture diagrams"
      - "Flow charts"
```

## Notes

- Repositories with active development are prioritized
- README quality is a key factor in scoring
- Images are downloaded to `images/{task_id}/{slug}/`
- Duplicate detection based on repository full name
