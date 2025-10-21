#!/bin/bash
# 前置检查：验证项目配置和创建必要目录

set -e

PROJECT_ROOT="$(pwd)"

# 检查任务目录
if [ ! -d "$PROJECT_ROOT/config/tasks" ]; then
  echo "❌ 错误：任务目录不存在"
  echo ""
  echo "请先创建任务："
  echo "  /mission add"
  echo ""
  exit 1
fi

# 创建必要目录
mkdir -p "$PROJECT_ROOT/temp/sessions"
mkdir -p "$PROJECT_ROOT/temp/cache"
mkdir -p "$PROJECT_ROOT/posts"
mkdir -p "$PROJECT_ROOT/logs"

echo "✅ 前置检查通过"
echo ""
