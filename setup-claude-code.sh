#!/bin/bash

# Claude Code Configuration Setup
# Supports bidirectional sync between repo/.claude and ~/.claude

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CLAUDE_DIR="$SCRIPT_DIR/.claude"
GLOBAL_CLAUDE_DIR="$HOME/.claude"

show_usage() {
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  export    Copy .claude from this repo to ~/.claude"
    echo "  import    Copy ~/.claude into this repo"
    echo ""
}

# Export: repo -> ~/.claude
do_export() {
    echo "Exporting .claude from repo to ~/.claude..."

    if [[ ! -d "$REPO_CLAUDE_DIR" ]]; then
        echo "Error: $REPO_CLAUDE_DIR does not exist"
        exit 1
    fi

    mkdir -p "$GLOBAL_CLAUDE_DIR"

    # Backup and copy CLAUDE.md
    if [[ -f "$REPO_CLAUDE_DIR/CLAUDE.md" ]]; then
        if [[ -f "$GLOBAL_CLAUDE_DIR/CLAUDE.md" ]]; then
            cp "$GLOBAL_CLAUDE_DIR/CLAUDE.md" "$GLOBAL_CLAUDE_DIR/CLAUDE.md.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        cp "$REPO_CLAUDE_DIR/CLAUDE.md" "$GLOBAL_CLAUDE_DIR/CLAUDE.md"
        echo "Copied CLAUDE.md"
    fi

    # Copy settings.json
    if [[ -f "$REPO_CLAUDE_DIR/settings.json" ]]; then
        if [[ -f "$GLOBAL_CLAUDE_DIR/settings.json" ]]; then
            cp "$GLOBAL_CLAUDE_DIR/settings.json" "$GLOBAL_CLAUDE_DIR/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        cp "$REPO_CLAUDE_DIR/settings.json" "$GLOBAL_CLAUDE_DIR/settings.json"
        echo "Copied settings.json"
    fi

    # Copy skills directory
    if [[ -d "$REPO_CLAUDE_DIR/skills" ]]; then
        rm -rf "$GLOBAL_CLAUDE_DIR/skills"
        cp -r "$REPO_CLAUDE_DIR/skills" "$GLOBAL_CLAUDE_DIR/"
        echo "Copied skills/"
    fi

    echo "Export complete"
}

# Import: ~/.claude -> repo
do_import() {
    echo "Importing ~/.claude into repo..."

    if [[ ! -d "$GLOBAL_CLAUDE_DIR" ]]; then
        echo "Error: ~/.claude does not exist"
        exit 1
    fi

    mkdir -p "$REPO_CLAUDE_DIR"

    # Copy CLAUDE.md
    if [[ -f "$GLOBAL_CLAUDE_DIR/CLAUDE.md" ]]; then
        cp "$GLOBAL_CLAUDE_DIR/CLAUDE.md" "$REPO_CLAUDE_DIR/CLAUDE.md"
        echo "Copied CLAUDE.md"
    fi

    # Copy settings.json
    if [[ -f "$GLOBAL_CLAUDE_DIR/settings.json" ]]; then
        cp "$GLOBAL_CLAUDE_DIR/settings.json" "$REPO_CLAUDE_DIR/settings.json"
        echo "Copied settings.json"
    fi

    # Copy skills directory
    if [[ -d "$GLOBAL_CLAUDE_DIR/skills" ]]; then
        rm -rf "$REPO_CLAUDE_DIR/skills"
        cp -r "$GLOBAL_CLAUDE_DIR/skills" "$REPO_CLAUDE_DIR/"
        echo "Copied skills/"
    fi

    echo "Import complete"
}

case "${1:-}" in
    export)
        do_export
        ;;
    import)
        do_import
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
