#!/bin/bash
#
# 图片下载辅助函数
#
# 提供给 Claude Agent 使用的图片下载工具
#

# 下载单张图片
# Usage: download_image <url> <output_path>
# Returns: 0 if success, 1 if failed
download_image() {
    local url="$1"
    local output_path="$2"

    if [ -z "$url" ] || [ -z "$output_path" ]; then
        echo "Error: URL and output path required" >&2
        return 1
    fi

    # 创建目录
    mkdir -p "$(dirname "$output_path")"

    # 下载图片
    # --max-filesize: 最大 5MB (5242880 bytes)
    # --connect-timeout: 连接超时 10 秒
    # --max-time: 总超时 30 秒
    # -L: 跟随重定向
    # -f: 失败时静默退出
    curl -L -f \
         --max-filesize 5242880 \
         --connect-timeout 10 \
         --max-time 30 \
         -o "$output_path" \
         "$url" 2>/dev/null

    local exit_code=$?

    if [ $exit_code -eq 0 ] && [ -f "$output_path" ]; then
        # 检查文件大小（不为空）
        local size=$(stat -f%z "$output_path" 2>/dev/null || stat -c%s "$output_path" 2>/dev/null)
        if [ "$size" -gt 0 ]; then
            echo "✓ Downloaded: $output_path ($(numfmt --to=iec $size 2>/dev/null || echo ${size}))" >&2
            return 0
        fi
    fi

    # 清理失败的文件
    rm -f "$output_path" 2>/dev/null
    echo "✗ Failed to download: $url" >&2
    return 1
}

# 获取图片尺寸
# Usage: get_image_size <image_path>
# Output: WIDTHxHEIGHT (e.g., "1200x630")
get_image_size() {
    local image_path="$1"

    if [ ! -f "$image_path" ]; then
        echo "0x0"
        return 1
    fi

    # 尝试使用 ImageMagick identify（如果可用）
    if command -v identify >/dev/null 2>&1; then
        identify -format '%wx%h' "$image_path" 2>/dev/null && return 0
    fi

    # Fallback: 使用 file 命令
    if command -v file >/dev/null 2>&1; then
        local size=$(file "$image_path" | grep -oE '[0-9]+\s*x\s*[0-9]+' | head -1 | tr -d ' ')
        if [ -n "$size" ]; then
            echo "$size"
            return 0
        fi
    fi

    # 无法检测
    echo "unknown"
    return 1
}

# 检查图片是否有效
# Usage: validate_image <image_path>
# Returns: 0 if valid, 1 if invalid
validate_image() {
    local image_path="$1"

    if [ ! -f "$image_path" ]; then
        return 1
    fi

    # 检查文件大小
    local size=$(stat -f%z "$image_path" 2>/dev/null || stat -c%s "$image_path" 2>/dev/null)
    if [ -z "$size" ] || [ "$size" -lt 100 ]; then
        return 1
    fi

    # 检查文件类型（魔数）
    if command -v file >/dev/null 2>&1; then
        local file_type=$(file -b --mime-type "$image_path")
        if [[ "$file_type" =~ ^image/ ]]; then
            return 0
        fi
    fi

    # 基础检查通过
    return 0
}

# 批量下载图片
# Usage: download_images_json <json_file>
# JSON 格式: [{"url": "...", "path": "..."}, ...]
download_images_json() {
    local json_file="$1"

    if [ ! -f "$json_file" ]; then
        echo "Error: JSON file not found: $json_file" >&2
        return 1
    fi

    # 检查 jq 是否可用
    if ! command -v jq >/dev/null 2>&1; then
        echo "Error: jq is required but not installed" >&2
        return 1
    fi

    local success=0
    local failed=0

    # 解析 JSON 并下载
    jq -c '.[]' "$json_file" | while IFS= read -r item; do
        local url=$(echo "$item" | jq -r '.url')
        local path=$(echo "$item" | jq -r '.path')

        if download_image "$url" "$path"; then
            ((success++))
        else
            ((failed++))
        fi
    done

    echo ""
    echo "Download summary: $success succeeded, $failed failed"

    [ $failed -eq 0 ] && return 0 || return 1
}

# 创建图片目录结构
# Usage: create_image_dir <task_id> <slug>
create_image_dir() {
    local task_id="$1"
    local slug="$2"
    local base_dir="blog/source/images"

    local dir="$base_dir/$task_id/$slug"
    mkdir -p "$dir"
    echo "$dir"
}

# 清理无效图片
# Usage: cleanup_invalid_images <directory>
cleanup_invalid_images() {
    local dir="$1"

    if [ ! -d "$dir" ]; then
        return 0
    fi

    local cleaned=0

    find "$dir" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.svg" \) | while read -r img; do
        if ! validate_image "$img"; then
            echo "Removing invalid image: $img" >&2
            rm -f "$img"
            ((cleaned++))
        fi
    done

    [ $cleaned -gt 0 ] && echo "Cleaned $cleaned invalid images"
    return 0
}

# 如果直接运行脚本，显示帮助
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    cat <<EOF
Image Download Utilities

Usage:
    source scripts/discover/image_utils.sh

Functions:
    download_image <url> <output_path>
        Download a single image

    get_image_size <image_path>
        Get image dimensions (WIDTHxHEIGHT)

    validate_image <image_path>
        Check if image is valid

    create_image_dir <task_id> <slug>
        Create image directory structure

    cleanup_invalid_images <directory>
        Remove invalid images from directory

Example:
    source scripts/discover/image_utils.sh
    download_image "https://example.com/image.png" "blog/source/images/test/image.png"
    get_image_size "blog/source/images/test/image.png"
EOF
fi
