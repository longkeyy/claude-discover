#!/bin/bash
# Send text file to Telegram channel (MarkdownV2 format)

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | grep -v '^$' | xargs)
fi

# Check required variables
if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHANNEL_ID" ]; then
    echo "❌ Error: TELEGRAM_BOT_TOKEN and TELEGRAM_CHANNEL_ID required"
    exit 1
fi

# Read file
if [ -z "$1" ]; then
    echo "Usage: $0 <text_file>"
    exit 1
fi

MESSAGE=$(cat "$1")

# Split long messages if needed (Telegram limit is 4096 characters)
MESSAGE_LENGTH=${#MESSAGE}
if [ $MESSAGE_LENGTH -gt 4000 ]; then
    echo "⚠️  Message too long ($MESSAGE_LENGTH chars), splitting..."

    # Split into chunks
    PART=1
    echo "$MESSAGE" | fold -w 3900 -s | while IFS= read -r CHUNK; do
        if [ -n "$CHUNK" ]; then
            RESPONSE=$(curl -s -X POST \
                "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
                -H "Content-Type: application/json" \
                -d @- << EOF
{
    "chat_id": "$TELEGRAM_CHANNEL_ID",
    "text": $(echo "$CHUNK" | jq -Rs .),
    "parse_mode": "MarkdownV2",
    "disable_web_page_preview": true
}
EOF
)
            if echo "$RESPONSE" | jq -e '.ok' > /dev/null 2>&1; then
                MSG_ID=$(echo "$RESPONSE" | jq -r '.result.message_id')
                echo "✅ Part $PART sent! ID: $MSG_ID"
                PART=$((PART + 1))
                sleep 1
            else
                ERROR=$(echo "$RESPONSE" | jq -r '.description // "Unknown error"')
                echo "❌ Failed part $PART: $ERROR"
            fi
        fi
    done
else
    # Send as single message
    RESPONSE=$(curl -s -X POST \
        "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -H "Content-Type: application/json" \
        -d @- << EOF
{
    "chat_id": "$TELEGRAM_CHANNEL_ID",
    "text": $(echo "$MESSAGE" | jq -Rs .),
    "parse_mode": "MarkdownV2",
    "disable_web_page_preview": true
}
EOF
)

    if echo "$RESPONSE" | jq -e '.ok' > /dev/null 2>&1; then
        MSG_ID=$(echo "$RESPONSE" | jq -r '.result.message_id')
        echo "✅ Message sent successfully! ID: $MSG_ID"
        echo "$MSG_ID"
    else
        ERROR=$(echo "$RESPONSE" | jq -r '.description // "Unknown error"')
        echo "❌ Failed: $ERROR"
        exit 1
    fi
fi
