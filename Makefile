.PHONY: help test build clean install publish

# Default target
help:
	@echo "Content Discovery Plugin - Build & Release"
	@echo ""
	@echo "Available targets:"
	@echo "  make test      - Run plugin validation tests"
	@echo "  make build     - Build plugin package"
	@echo "  make clean     - Clean build artifacts"
	@echo "  make install   - Install plugin locally (requires Claude Code)"
	@echo "  make publish   - Publish to GitHub (creates tag and pushes)"
	@echo ""
	@echo "Development workflow:"
	@echo "  1. make test          # Validate plugin"
	@echo "  2. make build         # Build package"
	@echo "  3. make install       # Test locally"
	@echo "  4. make publish       # Release to GitHub"

# Run validation tests
test:
	@echo "🧪 Running plugin tests..."
	@./scripts/test-plugin.sh

# Build plugin package
build: test
	@echo "🔨 Building plugin package..."
	@./scripts/build-plugin.sh

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf build/ dist/
	@echo "✅ Clean complete"

# Install plugin locally
install: build
	@echo "📦 Installing plugin locally..."
	@echo ""
	@echo "⚠️  Manual step required:"
	@echo "  Run in Claude Code CLI:"
	@echo "    /plugin install $$(pwd)/.claude-plugin"
	@echo ""

# Publish to GitHub (interactive)
publish: test
	@echo "🚀 Publishing plugin to GitHub..."
	@echo ""
	@# Get current version
	@VERSION=$$(jq -r '.version' .claude-plugin/plugin.json); \
	echo "Current version: $$VERSION"; \
	echo ""; \
	echo "This will:"; \
	echo "  1. Create git tag: v$$VERSION"; \
	echo "  2. Push tag to GitHub"; \
	echo "  3. Trigger GitHub Actions to build and release"; \
	echo ""; \
	read -p "Continue? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo ""; \
		echo "📝 Creating git tag v$$VERSION..."; \
		git tag -a "v$$VERSION" -m "Release v$$VERSION"; \
		echo "⬆️  Pushing tag to GitHub..."; \
		git push origin "v$$VERSION"; \
		echo ""; \
		echo "✅ Tag pushed successfully!"; \
		echo ""; \
		echo "🤖 GitHub Actions will now:"; \
		echo "  - Build the plugin package"; \
		echo "  - Create a GitHub release"; \
		echo "  - Upload plugin.zip and checksum"; \
		echo ""; \
		echo "📦 Monitor progress at:"; \
		echo "  https://github.com/$$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/actions"; \
	else \
		echo ""; \
		echo "❌ Publish cancelled"; \
		exit 1; \
	fi

# Version bump helpers
.PHONY: version-patch version-minor version-major

version-patch:
	@./scripts/bump-version.sh patch

version-minor:
	@./scripts/bump-version.sh minor

version-major:
	@./scripts/bump-version.sh major
