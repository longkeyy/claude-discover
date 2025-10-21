---
# Task Configuration Example: ArXiv Papers
# Copy this to config/tasks/ and customize for your needs
# File name should be: {task-id}.md (lowercase, kebab-case)

name: "AI Research Papers"
task_id: "ai-papers"
description: "Discover latest AI/ML research papers from ArXiv"
enabled: true
---

# ArXiv Papers Discovery Task

## Data Sources

### ArXiv (Primary)
- **Enabled**: true
- **Categories**: cs.AI, cs.LG, cs.CL, cs.CV
- **Time Range**: last_7_days
- **Min Citations**: N/A (for recent papers)

## Filtering Rules

```yaml
filters:
  time_range: "last_7_days"
  categories:
    - "cs.AI"   # Artificial Intelligence
    - "cs.LG"   # Machine Learning
    - "cs.CL"   # Computation and Language
    - "cs.CV"   # Computer Vision

  # Author filtering (optional)
  author_email_domains:
    - "@openai.com"
    - "@anthropic.com"
    - "@deepmind.com"
    - "@meta.com"

  # Quality criteria
  minimum_quality_score: 75
```

## Content Quality Standards

- **Language**: Chinese summaries required
- **Minimum Length**: 1000 characters
- **Required Fields**:
  - arxiv_url
  - title
  - authors
  - abstract
  - summary (AI-generated Chinese)

## Scoring Weights

```yaml
scoring_weights:
  recency: 0.3       # How recent the paper is
  relevance: 0.4     # Match with keywords
  completeness: 0.2  # Has abstract, PDF, etc.
  novelty: 0.1       # New concepts/methods
```

## Publishing Configuration

### Hexo Blog
```yaml
hexo:
  enabled: true
  post_dir: "source/_posts/papers"
  template: |
    ---
    title: {{ title }}
    date: {{ date }}
    categories: [papers]
    tags: {{ tags }}
    arxiv_url: {{ arxiv_url }}
    ---

    {{ summary }}

    ## Abstract
    {{ abstract }}

    ## Authors
    {{ authors }}
```

### Telegram Channel
```yaml
telegram:
  enabled: true
  channel_id: "@your_channel"
  format: |
    📄 **{{ title }}**

    {{ summary_short }}

    🔗 ArXiv: {{ arxiv_url }}
    👥 Authors: {{ authors }}
    🏷 Tags: {{ tags }}
```

### Discord Webhook
```yaml
discord:
  enabled: false
  webhook_url: "https://discord.com/api/webhooks/..."
```

## Notes

- Papers are published immediately after quality validation
- Duplicate detection uses title and abstract similarity
- Images (diagrams) are extracted from PDF when available
