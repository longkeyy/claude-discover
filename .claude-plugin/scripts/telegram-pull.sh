#!/bin/bash
# Telegram Channel History Puller
# 快速拉取公开频道的历史消息

set -e

# 加载环境变量
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | grep -v '^$' | xargs)
fi

# 检查必需参数
CHANNEL_USERNAME="${1:-$TELEGRAM_CHANNEL_ID}"

if [ -z "$CHANNEL_USERNAME" ]; then
    echo "❌ Error: Channel username required"
    echo "Usage: $0 @channel_name [limit]"
    echo "   or: Set TELEGRAM_CHANNEL_ID in .env"
    exit 1
fi

# 去除 @ 符号
CHANNEL_USERNAME="${CHANNEL_USERNAME#@}"

# 配置
LIMIT=${2:-100}
CACHE_DIR=".cache"
OUTPUT_FILE="$CACHE_DIR/telegram-messages-${CHANNEL_USERNAME}.json"
TEMP_HTML="$CACHE_DIR/telegram-temp.html"

mkdir -p "$CACHE_DIR"

echo "📡 Telegram Channel History Puller"
echo "📺 Channel: @$CHANNEL_USERNAME"
echo "🔢 Limit: $LIMIT messages"
echo ""

# 公开频道的网页 URL
WEB_URL="https://t.me/s/$CHANNEL_USERNAME"

echo "🌐 Fetching from: $WEB_URL"

# 拉取网页内容
curl -s "$WEB_URL" -o "$TEMP_HTML"

if [ ! -s "$TEMP_HTML" ]; then
    echo "❌ Failed to fetch channel page"
    exit 1
fi

echo "✅ Page fetched"
echo "📝 Parsing messages..."

# 解析消息（使用 grep 和 sed 提取 JSON 数据）
# Telegram 网页版在 tgme_widget_message 类中包含消息

MESSAGES="[]"
COUNT=0

# 提取消息块
grep -o 'class="tgme_widget_message[^"]*"[^>]*>[^<]*<.*</div>' "$TEMP_HTML" | head -n $LIMIT | while IFS= read -r line; do
    # 提取消息 ID
    MSG_ID=$(echo "$line" | grep -o 'data-post="[^"]*"' | sed 's/data-post="[^/]*\/\([0-9]*\)"/\1/' || echo "0")

    # 提取时间
    DATETIME=$(echo "$line" | grep -o '<time[^>]*datetime="[^"]*"' | sed 's/.*datetime="\([^"]*\)".*/\1/' || echo "")

    # 提取消息文本
    TEXT=$(echo "$line" | sed 's/<[^>]*>//g' | sed 's/&quot;/"/g' | sed 's/&amp;/\&/g' | sed 's/&lt;/</g' | sed 's/&gt;/>/g' | tr -d '\n' | sed 's/^[ \t]*//;s/[ \t]*$//')

    if [ -n "$MSG_ID" ] && [ "$MSG_ID" != "0" ]; then
        MSG_OBJ=$(cat <<EOF
{
    "message_id": $MSG_ID,
    "date": "$DATETIME",
    "text": $(echo "$TEXT" | jq -Rs .),
    "url": "https://t.me/$CHANNEL_USERNAME/$MSG_ID",
    "pulled_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
)
        echo "$MSG_OBJ"
    fi
done | jq -s '.' > "$OUTPUT_FILE.tmp"

# 检查是否成功解析
if [ -s "$OUTPUT_FILE.tmp" ]; then
    mv "$OUTPUT_FILE.tmp" "$OUTPUT_FILE"
    COUNT=$(cat "$OUTPUT_FILE" | jq 'length')
    echo "✅ Parsed $COUNT messages"
else
    echo "⚠️  No messages parsed, trying alternative method..."

    # 替代方案：使用更简单的解析
    grep -o 'data-post="[^"]*"' "$TEMP_HTML" | head -n $LIMIT | while IFS= read -r post; do
        MSG_ID=$(echo "$post" | sed 's/data-post="[^/]*\/\([0-9]*\)"/\1/')

        MSG_OBJ=$(cat <<EOF
{
    "message_id": $MSG_ID,
    "url": "https://t.me/$CHANNEL_USERNAME/$MSG_ID",
    "pulled_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
)
        echo "$MSG_OBJ"
    done | jq -s '.' > "$OUTPUT_FILE"

    COUNT=$(cat "$OUTPUT_FILE" | jq 'length')
    echo "✅ Parsed $COUNT message IDs"
fi

# 清理临时文件
rm -f "$TEMP_HTML" "$OUTPUT_FILE.tmp"

# 保存最终结果
FINAL_OUTPUT=$(cat <<EOF
{
    "channel": {
        "username": "$CHANNEL_USERNAME",
        "url": "$WEB_URL"
    },
    "pulled_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "count": $COUNT,
    "messages": $(cat "$OUTPUT_FILE")
}
EOF
)

echo "$FINAL_OUTPUT" | jq '.' > "$OUTPUT_FILE"
echo "💾 Saved to: $OUTPUT_FILE"

# 显示统计
echo ""
echo "📊 Statistics:"
echo "  Total messages: $COUNT"

if [ "$COUNT" -gt 0 ]; then
    echo ""
    echo "📋 Latest messages:"
    cat "$OUTPUT_FILE" | jq -r '.messages[:5] | .[] | "  - [\(.message_id)] \(.url)"'
fi

echo ""
echo "💡 Tip: View full data with: jq '.' $OUTPUT_FILE"
