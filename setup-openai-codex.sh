#!/bin/bash

# OpenAI Codex Installation & Configuration Script
# Installs @openai/codex and links shared config from dotfiles

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "OpenAI Codex Setup"
echo ""

# --- Helpers (same pattern as setup-macos.sh) ---

link_file() {
    local src="$1" dest="$2"
    if [[ ! -f "$src" ]]; then
        echo "  skip $(basename "$dest") (not found in dotfiles)"
        return
    fi
    if [[ -L "$dest" ]]; then
        rm "$dest"
    elif [[ -f "$dest" ]]; then
        mv "$dest" "$dest.bak"
        echo "  backup $dest -> $dest.bak"
    fi
    ln -s "$src" "$dest"
    echo "  link $dest"
}

link_dir() {
    local src="$1" dest="$2"
    if [[ ! -d "$src" ]]; then
        echo "  skip $(basename "$dest") (not found in dotfiles)"
        return
    fi
    if [[ -L "$dest" ]]; then
        rm "$dest"
    elif [[ -d "$dest" ]]; then
        mv "$dest" "$dest.bak"
        echo "  backup $dest -> $dest.bak"
    fi
    ln -s "$src" "$dest"
    echo "  link $dest"
}

# --- Install Codex CLI ---

# Ensure NVM is loaded if available
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Check if npm is available
if ! command -v npm &>/dev/null; then
    echo "npm not found. Please install Node.js first."
    echo ""
    echo "Options:"
    echo "  1. Run ./setup-macos.sh to install NVM and Node.js"
    echo "  2. Visit https://nodejs.org/ to download Node.js"
    echo "  3. Install NVM: https://github.com/nvm-sh/nvm"
    exit 1
fi

# Check if @openai/codex is already installed
if npm list -g @openai/codex &>/dev/null; then
    echo "@openai/codex is already installed"

    # Show current version
    CURRENT_VERSION=$(npm list -g @openai/codex --depth=0 2>/dev/null | grep @openai/codex | awk '{print $2}' | tr -d '@')
    echo "   Current version: $CURRENT_VERSION"
    echo ""

    read -p "Do you want to update it? (y/n): " response
    case "$response" in
        [Yy]* )
            echo "Updating @openai/codex..."
            npm update -g @openai/codex
            echo "@openai/codex updated"
            ;;
        * )
            echo "Skipping update"
            ;;
    esac
else
    echo "Installing @openai/codex..."
    npm install -g @openai/codex
    echo "@openai/codex installed"
fi

# --- Link config from Obsidian vault ---

echo ""
echo "Linking Codex configuration..."

if [[ ! -L "$HOME/src/obsidian" ]]; then
    echo "Error: ~/src/obsidian symlink not found. Run setup-macos.sh first."
    exit 1
fi

# Codex config: ~/.codex/config.toml and AGENTS.md (shared with Claude Code)
mkdir -p "$HOME/.codex"
link_file "$HOME/src/obsidian/projects/claude/codex-config.toml" "$HOME/.codex/config.toml"
link_file "$HOME/src/obsidian/projects/claude/CLAUDE.md" "$HOME/.codex/AGENTS.md"

# Shared agent skills
mkdir -p "$HOME/.agents"
link_dir "$HOME/src/obsidian/projects/claude/skills" "$HOME/.agents/skills"

echo ""
echo "Setup complete!"
echo ""
