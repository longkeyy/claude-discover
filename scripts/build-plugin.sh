#!/usr/bin/env bash
# Build plugin package for distribution

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PLUGIN_DIR="$PROJECT_ROOT/.claude-plugin"
BUILD_DIR="$PROJECT_ROOT/build"
DIST_DIR="$PROJECT_ROOT/dist"

echo "🔨 Building Content Discovery Plugin..."

# Clean previous builds
rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR"

# Copy plugin files
echo "📦 Copying plugin files..."
cp -r "$PLUGIN_DIR"/* "$BUILD_DIR/"

# Copy root-level documentation
echo "📄 Copying documentation..."
cp "$PROJECT_ROOT/ARCHITECTURE.md" "$BUILD_DIR/"
cp "$PROJECT_ROOT/CHANGELOG.md" "$BUILD_DIR/"

# Copy example configs
echo "⚙️  Copying example configs..."
mkdir -p "$BUILD_DIR/examples"
cp -r "$PROJECT_ROOT/config/tasks/.template.md" "$BUILD_DIR/examples/"
[ -f "$PROJECT_ROOT/.env.example" ] && cp "$PROJECT_ROOT/.env.example" "$BUILD_DIR/examples/"

# Validate plugin.json
echo "✅ Validating plugin.json..."
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not found, skipping validation"
else
    if jq empty "$BUILD_DIR/plugin.json" 2>/dev/null; then
        echo "✅ plugin.json is valid JSON"
    else
        echo "❌ plugin.json is invalid JSON"
        exit 1
    fi
fi

# Get version from plugin.json
VERSION=$(jq -r '.version' "$BUILD_DIR/plugin.json")
echo "📌 Plugin version: $VERSION"

# Create zip package
PACKAGE_NAME="content-discovery-${VERSION}.zip"
echo "📦 Creating package: $PACKAGE_NAME..."

cd "$BUILD_DIR"
zip -r "$DIST_DIR/$PACKAGE_NAME" . -x "*.git*" -x "*.DS_Store"
cd "$PROJECT_ROOT"

# Create checksum
echo "🔐 Generating checksum..."
cd "$DIST_DIR"
shasum -a 256 "$PACKAGE_NAME" > "${PACKAGE_NAME}.sha256"
cd "$PROJECT_ROOT"

# Summary
echo ""
echo "✅ Build complete!"
echo "📦 Package: $DIST_DIR/$PACKAGE_NAME"
echo "🔐 Checksum: $DIST_DIR/${PACKAGE_NAME}.sha256"
echo ""
echo "To test locally:"
echo "  /plugin install $BUILD_DIR"
echo ""
echo "To publish:"
echo "  1. Create GitHub release: gh release create v${VERSION}"
echo "  2. Upload package: gh release upload v${VERSION} $DIST_DIR/$PACKAGE_NAME"
