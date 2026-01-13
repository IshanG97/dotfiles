#!/bin/bash

set -e

echo "🚀 Starting macOS setup..."

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is only for macOS"
    exit 1
fi

# Function to prompt for yes/no
prompt_yes_no() {
    local prompt="$1"
    local response
    while true; do
        read -p "$prompt (y/n): " response
        case "$response" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y or n.";;
        esac
    done
}

echo ""
echo "📋 Let's configure what to install..."
echo ""

# Ask about each component upfront
INSTALL_XCODE=false
INSTALL_HOMEBREW=false
INSTALL_GIT=false
INSTALL_UV=false
INSTALL_GIT_FILTER_REPO=false
INSTALL_GIT_LFS=false
INSTALL_TMUX=false
INSTALL_NVIM=false
INSTALL_BRAVE=false
INSTALL_VSCODE=false
INSTALL_VSCODE_CLI=false
INSTALL_NVM=false
INSTALL_NODE=false
INSTALL_CLAUDE_CODE=false
INSTALL_PYENV=false
INSTALL_PYTHON=false
INSTALL_LUNAR=false
INSTALL_MACCY=false
INSTALL_RAYCAST=false
INSTALL_GHOSTTY=false
INSTALL_AEROSPACE=false
INSTALL_GOOGLE_CHROME=false
INSTALL_PLEX=false
INSTALL_GOOGLE_DRIVE=false
INSTALL_TRANSMISSION=false
INSTALL_OBSIDIAN=false
INSTALL_WHATSAPP=false
INSTALL_SPOTIFY=false
INSTALL_LOGI_OPTIONS=false
INSTALL_CHATGPT=false
INSTALL_ADB=false
INSTALL_SCRCPY=false
INSTALL_BORDERS=false
INSTALL_SHOTTR=false
INSTALL_WINDOWS_APP=false
INSTALL_MYSQL=false
COPY_GHOSTTY_CONFIG=false
COPY_AEROSPACE_CONFIG=false
DISABLE_SPOTLIGHT=false
MOVE_DOCK_LEFT=false

# Check Xcode
if ! xcode-select -p &>/dev/null; then
    if prompt_yes_no "📦 Install Xcode Command Line Tools?"; then
        INSTALL_XCODE=true
    fi
else
    echo "✅ Xcode Command Line Tools already installed"
fi

# Check Homebrew
if ! command -v brew &>/dev/null; then
    if prompt_yes_no "🍺 Install Homebrew?"; then
        INSTALL_HOMEBREW=true
    fi
else
    echo "✅ Homebrew already installed"
    INSTALL_HOMEBREW=true  # Mark as true so we can install brew packages
fi

# Only ask about Homebrew-dependent tools if Homebrew will be available
if [[ "$INSTALL_HOMEBREW" == true ]] || command -v brew &>/dev/null; then
    # Check Git
    if ! command -v git &>/dev/null; then
        if prompt_yes_no "📚 Install Git?"; then
            INSTALL_GIT=true
        fi
    else
        echo "✅ Git already installed"
    fi

    # Check git-filter-repo
    if ! command -v git-filter-repo &>/dev/null; then
        if prompt_yes_no "🧹 Install git-filter-repo?"; then
            INSTALL_GIT_FILTER_REPO=true
        fi
    else
        echo "✅ git-filter-repo already installed"
    fi

    # Check git-lfs
    if ! command -v git-lfs &>/dev/null; then
        if prompt_yes_no "📦 Install git-lfs (Git Large File Storage)?"; then
            INSTALL_GIT_LFS=true
        fi
    else
        echo "✅ git-lfs already installed"
    fi

    # Check tmux
    if ! command -v tmux &>/dev/null; then
        if prompt_yes_no "💻 Install tmux (terminal multiplexer)?"; then
            INSTALL_TMUX=true
        fi
    else
        echo "✅ tmux already installed"
    fi

    # Check nvim
    if ! command -v nvim &>/dev/null; then
        if prompt_yes_no "📝 Install Neovim (text editor)?"; then
            INSTALL_NVIM=true
        fi
    else
        echo "✅ Neovim already installed"
    fi

    # Check pyenv
    if ! command -v pyenv &>/dev/null; then
        if prompt_yes_no "🐍 Install pyenv (Python version manager)?"; then
            INSTALL_PYENV=true
            # Ask about Python if installing pyenv
            if prompt_yes_no "   Install Python via pyenv?"; then
                INSTALL_PYTHON=true
                read -p "   Enter Python version (e.g., 3.13): " PYTHON_VERSION
            fi
        fi
    else
        echo "✅ pyenv already installed"
        # Ask about Python if pyenv exists but no global Python set
        if ! pyenv global &>/dev/null || [[ "$(pyenv global)" == "system" ]]; then
            if prompt_yes_no "🐍 Install Python via pyenv?"; then
                INSTALL_PYTHON=true
                read -p "   Enter Python version (e.g., 3.13): " PYTHON_VERSION
            fi
        else
            echo "✅ Python already configured via pyenv: $(pyenv global)"
        fi
    fi

    # Check Brave Browser
    if ! ls /Applications/ 2>/dev/null | grep -qi "brave"; then
        if prompt_yes_no "🦁 Install Brave Browser?"; then
            INSTALL_BRAVE=true
        fi
    else
        echo "✅ Brave Browser already installed"
    fi

    # Check Lunar
    if ! ls /Applications/ 2>/dev/null | grep -qi "lunar"; then
        if prompt_yes_no "🌙 Install Lunar (display brightness control)?"; then
            INSTALL_LUNAR=true
        fi
    else
        echo "✅ Lunar already installed"
    fi

    # Check Maccy
    if ! command -v maccy &>/dev/null && ! ls /Applications/ 2>/dev/null | grep -qi "maccy"; then
        if prompt_yes_no "📋 Install Maccy (clipboard manager)?"; then
            INSTALL_MACCY=true
        fi
    else
        echo "✅ Maccy already installed"
    fi

    # Check Raycast
    if ! ls /Applications/ 2>/dev/null | grep -qi "raycast"; then
        if prompt_yes_no "🔍 Install Raycast (productivity launcher)?"; then
            INSTALL_RAYCAST=true
            # Ask about disabling Spotlight if installing Raycast
            if prompt_yes_no "   Disable Spotlight keyboard shortcut (Cmd+Space)?"; then
                DISABLE_SPOTLIGHT=true
            fi
        fi
    else
        echo "✅ Raycast already installed"
        # Ask about Spotlight even if Raycast is already installed
        if prompt_yes_no "🔍 Disable Spotlight keyboard shortcut (Cmd+Space)?"; then
            DISABLE_SPOTLIGHT=true
        fi
    fi

    # Check Ghostty
    if ! ls /Applications/ 2>/dev/null | grep -qi "ghostty"; then
        if prompt_yes_no "👻 Install Ghostty (terminal emulator)?"; then
            INSTALL_GHOSTTY=true
            # Ask about config if installing Ghostty
            if [ -f ".config/ghostty/config" ]; then
                if prompt_yes_no "   Copy Ghostty config from dotfiles to ~/.config/ghostty?"; then
                    COPY_GHOSTTY_CONFIG=true
                fi
            fi
        fi
    else
        echo "✅ Ghostty already installed"
        # Ask about config if Ghostty exists
        if [ -f ".config/ghostty/config" ]; then
            if prompt_yes_no "👻 Copy Ghostty config from dotfiles to ~/.config/ghostty?"; then
                COPY_GHOSTTY_CONFIG=true
            fi
        fi
    fi

    # Check AeroSpace
    if ! ls /Applications/ 2>/dev/null | grep -qi "aerospace"; then
        if prompt_yes_no "✈️  Install AeroSpace (tiling window manager)?"; then
            INSTALL_AEROSPACE=true
            # Ask about config if installing AeroSpace
            if [ -f ".config/aerospace/aerospace.toml" ]; then
                if prompt_yes_no "   Copy AeroSpace config from dotfiles to ~/.config/aerospace?"; then
                    COPY_AEROSPACE_CONFIG=true
                fi
            fi
        fi
    else
        echo "✅ AeroSpace already installed"
        # Ask about config if AeroSpace exists
        if [ -f ".config/aerospace/aerospace.toml" ]; then
            if prompt_yes_no "✈️  Copy AeroSpace config from dotfiles to ~/.config/aerospace?"; then
                COPY_AEROSPACE_CONFIG=true
            fi
        fi
    fi

    # Check Google Chrome
    if ! ls /Applications/ 2>/dev/null | grep -qi "google chrome"; then
        if prompt_yes_no "🌐 Install Google Chrome?"; then
            INSTALL_GOOGLE_CHROME=true
        fi
    else
        echo "✅ Google Chrome already installed"
    fi

    # Check Plex Media Server
    if ! ls /Applications/ 2>/dev/null | grep -qi "plex"; then
        if prompt_yes_no "🎬 Install Plex Media Server?"; then
            INSTALL_PLEX=true
        fi
    else
        echo "✅ Plex Media Server already installed"
    fi

    # Check Google Drive
    if ! ls /Applications/ 2>/dev/null | grep -qi "google drive"; then
        if prompt_yes_no "☁️  Install Google Drive?"; then
            INSTALL_GOOGLE_DRIVE=true
        fi
    else
        echo "✅ Google Drive already installed"
    fi

    # Check Transmission
    if ! ls /Applications/ 2>/dev/null | grep -qi "transmission"; then
        if prompt_yes_no "📥 Install Transmission (BitTorrent client)?"; then
            INSTALL_TRANSMISSION=true
        fi
    else
        echo "✅ Transmission already installed"
    fi

    # Check Obsidian
    if ! ls /Applications/ 2>/dev/null | grep -qi "obsidian"; then
        if prompt_yes_no "📝 Install Obsidian (note-taking app)?"; then
            INSTALL_OBSIDIAN=true
        fi
    else
        echo "✅ Obsidian already installed"
    fi

    # Check WhatsApp
    if ! ls /Applications/ 2>/dev/null | grep -qi "whatsapp"; then
        if prompt_yes_no "💬 Install WhatsApp?"; then
            INSTALL_WHATSAPP=true
        fi
    else
        echo "✅ WhatsApp already installed"
    fi

    # Check Spotify
    if ! ls /Applications/ 2>/dev/null | grep -qi "spotify"; then
        if prompt_yes_no "🎵 Install Spotify?"; then
            INSTALL_SPOTIFY=true
        fi
    else
        echo "✅ Spotify already installed"
    fi

    # Check Logi Options+
    if ! ls /Applications/ 2>/dev/null | grep -qi "logioptionsplus"; then
        if prompt_yes_no "🖱️  Install Logi Options+ (Logitech device manager)?"; then
            INSTALL_LOGI_OPTIONS=true
        fi
    else
        echo "✅ Logi Options+ already installed"
    fi

    # Check ChatGPT
    if ! ls /Applications/ 2>/dev/null | grep -qi "chatgpt"; then
        if prompt_yes_no "🤖 Install ChatGPT?"; then
            INSTALL_CHATGPT=true
        fi
    else
        echo "✅ ChatGPT already installed"
    fi

    # Check Android Platform Tools (ADB)
    if ! command -v adb &>/dev/null; then
        if prompt_yes_no "📱 Install Android Platform Tools (ADB)?"; then
            INSTALL_ADB=true
        fi
    else
        echo "✅ Android Platform Tools (ADB) already installed"
    fi

    # Check scrcpy
    if ! command -v scrcpy &>/dev/null; then
        if prompt_yes_no "📱 Install scrcpy (screen mirroring for Android)?"; then
            INSTALL_SCRCPY=true
        fi
    else
        echo "✅ scrcpy already installed"
    fi

    # Check borders
    if ! command -v borders &>/dev/null; then
        if prompt_yes_no "🔲 Install borders (window border highlights)?"; then
            INSTALL_BORDERS=true
        fi
    else
        echo "✅ borders already installed"
    fi

    # Check Shottr
    if ! ls /Applications/ 2>/dev/null | grep -qi "shottr"; then
        if prompt_yes_no "📸 Install Shottr (screenshot tool)?"; then
            INSTALL_SHOTTR=true
        fi
    else
        echo "✅ Shottr already installed"
    fi

    # Check Windows App
    if ! ls /Applications/ 2>/dev/null | grep -qi "windows app"; then
        if prompt_yes_no "🪟 Install Windows App (Microsoft Remote Desktop)?"; then
            INSTALL_WINDOWS_APP=true
        fi
    else
        echo "✅ Windows App already installed"
    fi

    # Check MySQL (combined: server, workbench, and shell)
    if ! command -v mysql &>/dev/null || ! ls /Applications/ 2>/dev/null | grep -qi "mysqlworkbench" || ! command -v mysqlsh &>/dev/null; then
        if prompt_yes_no "🗄️  Install MySQL (Server 8.4, Workbench, Shell)?"; then
            INSTALL_MYSQL=true
        fi
    else
        echo "✅ MySQL tools already installed"
    fi

    # Check Visual Studio Code
    if ! ls /Applications/ 2>/dev/null | grep -qi "visual studio code"; then
        if prompt_yes_no "💻 Install Visual Studio Code?"; then
            INSTALL_VSCODE=true
            # Ask about CLI if installing VS Code
            if prompt_yes_no "⚙️  Install VS Code CLI (code command)?"; then
                INSTALL_VSCODE_CLI=true
            fi
        fi
    else
        echo "✅ Visual Studio Code already installed"
        # Ask about CLI if VS Code exists but CLI doesn't
        if ! command -v code &>/dev/null; then
            if prompt_yes_no "⚙️  Install VS Code CLI (code command)?"; then
                INSTALL_VSCODE_CLI=true
            fi
        else
            echo "✅ VS Code CLI already available"
        fi
    fi
else
    echo "⚠️  Skipping Homebrew-dependent tools (Homebrew not selected)"
fi

# Check uv (not dependent on Homebrew)
if ! command -v uv &>/dev/null; then
    if prompt_yes_no "🐍 Install uv (Python package manager)?"; then
        INSTALL_UV=true
    fi
else
    echo "✅ uv already installed"
fi

# Check NVM (not dependent on Homebrew)
# NVM is a shell function, so we check for the directory and script file
if [[ ! -d "$HOME/.nvm" ]] || [[ ! -s "$HOME/.nvm/nvm.sh" ]]; then
    if prompt_yes_no "📦 Install NVM (Node Version Manager)?"; then
        INSTALL_NVM=true
        # Ask about Node.js if installing NVM
        if prompt_yes_no "   Install Node.js LTS via NVM?"; then
            INSTALL_NODE=true
        fi
    fi
else
    echo "✅ NVM already installed"
    # Load NVM to check for Node
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # Ask about Node.js if NVM exists but Node doesn't
    if ! command -v node &>/dev/null; then
        if prompt_yes_no "📦 Install Node.js LTS via NVM?"; then
            INSTALL_NODE=true
        fi
    else
        echo "✅ Node.js already installed"
        # Check npm separately
        if ! command -v npm &>/dev/null; then
            echo "⚠️  npm not found (this is unusual - npm usually comes with Node.js)"
            if prompt_yes_no "📦 Reinstall Node.js to get npm?"; then
                INSTALL_NODE=true
            fi
        else
            echo "✅ npm already installed"
        fi
    fi
fi

# Check Claude Code CLI
if ! command -v claude &>/dev/null; then
    if prompt_yes_no "🤖 Install Claude Code CLI (Anthropic)?"; then
        INSTALL_CLAUDE_CODE=true
    fi
else
    echo "✅ Claude Code CLI already installed"
fi

# macOS Appearance Settings
echo ""
echo "⚙️  macOS Appearance Settings"
echo ""

# Ask about dock position
CURRENT_DOCK_POSITION=$(defaults read com.apple.dock orientation 2>/dev/null || echo "bottom")
if [[ "$CURRENT_DOCK_POSITION" != "left" ]]; then
    if prompt_yes_no "🪟 Move Dock to left side of screen?"; then
        MOVE_DOCK_LEFT=true
    fi
else
    echo "✅ Dock already positioned on left"
fi

echo ""
echo "🚦 Starting installation based on your choices..."
echo ""

# Install Xcode Command Line Tools (required for git and other tools)
if [[ "$INSTALL_XCODE" == true ]]; then
    echo "📦 Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "⏳ Please complete the Xcode Command Line Tools installation and run this script again"
    exit 0
fi

# Install Homebrew
if [[ "$INSTALL_HOMEBREW" == true ]] && ! command -v brew &>/dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to .zshrc for zsh shell
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    echo "✅ Homebrew installed and added to .zshrc"
fi

# Ensure Homebrew is in .zshrc if already installed
if command -v brew &>/dev/null; then
    if ! grep -q "brew shellenv" ~/.zshrc 2>/dev/null; then
        echo "Adding Homebrew to .zshrc..."
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
        fi
        echo "✅ Homebrew added to .zshrc"
    fi
fi

# Update Homebrew
if command -v brew &>/dev/null; then
    echo "🔄 Updating Homebrew..."
    brew update
fi

# Install git
if [[ "$INSTALL_GIT" == true ]]; then
    echo "📚 Installing Git..."
    brew install git
    echo "✅ Git installed"
fi

# Install uv
if [[ "$INSTALL_UV" == true ]]; then
    echo "🐍 Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add uv to PATH in .zshrc
    export PATH="$HOME/.cargo/bin:$PATH"
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
    echo "✅ uv installed"
fi

# Install git-filter-repo
if [[ "$INSTALL_GIT_FILTER_REPO" == true ]]; then
    echo "🧹 Installing git-filter-repo..."
    brew install git-filter-repo
    echo "✅ git-filter-repo installed"
fi

# Install git-lfs
if [[ "$INSTALL_GIT_LFS" == true ]]; then
    echo "📦 Installing git-lfs..."
    brew install git-lfs
    git lfs install
    echo "✅ git-lfs installed"
fi

# Install tmux
if [[ "$INSTALL_TMUX" == true ]]; then
    echo "💻 Installing tmux..."
    brew install tmux
    echo "✅ tmux installed"
fi

# Install nvim
if [[ "$INSTALL_NVIM" == true ]]; then
    echo "📝 Installing Neovim..."
    brew install neovim
    echo "✅ Neovim installed"
fi

# Install pyenv
if [[ "$INSTALL_PYENV" == true ]]; then
    echo "🐍 Installing pyenv..."
    brew install pyenv

    # Add pyenv to .zshrc
    if ! grep -q 'eval "$(pyenv init -)"' ~/.zshrc 2>/dev/null; then
        echo '' >> ~/.zshrc
        echo '# pyenv configuration' >> ~/.zshrc
        echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
        echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
        echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
        echo 'eval "$(pyenv init -)"' >> ~/.zshrc
    fi

    # Load pyenv for this session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"

    echo "✅ pyenv installed"
fi

# Install Python via pyenv
if [[ "$INSTALL_PYTHON" == true ]]; then
    # Ensure pyenv is loaded
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"

    echo "🐍 Installing Python $PYTHON_VERSION via pyenv..."
    pyenv install "$PYTHON_VERSION"
    pyenv global "$PYTHON_VERSION"

    echo "✅ Python installed: $(python --version)"
    echo "✅ pip installed: $(pip --version)"
fi

# Install NVM
if [[ "$INSTALL_NVM" == true ]]; then
    echo "📦 Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
    echo "✅ NVM installed"

    # Load NVM for this session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Install Node.js via NVM
if [[ "$INSTALL_NODE" == true ]]; then
    # Ensure NVM is loaded
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    echo "📦 Installing Node.js LTS via NVM..."
    nvm install --lts
    nvm use --lts
    nvm alias default node
    echo "✅ Node.js installed: $(node --version)"
    echo "✅ npm installed: $(npm --version)"
fi

# Install Claude Code CLI
if [[ "$INSTALL_CLAUDE_CODE" == true ]]; then
    echo "🤖 Installing Claude Code CLI..."

    if ! command -v curl &>/dev/null; then
        echo "❌ curl is required for this installer but was not found"
        exit 1
    fi

    if curl -fsSL https://claude.ai/install.sh | bash; then
        echo "✅ Claude Code CLI installed"
    else
        echo "❌ Claude Code CLI installation failed"
        exit 1
    fi
fi



# Install applications via Homebrew Cask
# Brave Browser
if [[ "$INSTALL_BRAVE" == true ]]; then
    echo "🦁 Installing Brave Browser..."
    brew install --cask brave-browser
    echo "✅ Brave Browser installed"
fi

# Lunar
if [[ "$INSTALL_LUNAR" == true ]]; then
    echo "🌙 Installing Lunar..."
    brew install --cask lunar
    echo "✅ Lunar installed"
fi

# Maccy
if [[ "$INSTALL_MACCY" == true ]]; then
    echo "📋 Installing Maccy..."
    brew install maccy
    echo "✅ Maccy installed"
fi

# Raycast
if [[ "$INSTALL_RAYCAST" == true ]]; then
    echo "🔍 Installing Raycast..."
    brew install --cask raycast
    echo "✅ Raycast installed"
fi

# Visual Studio Code
if [[ "$INSTALL_VSCODE" == true ]]; then
    echo "💻 Installing Visual Studio Code..."
    brew install --cask visual-studio-code
    echo "✅ Visual Studio Code installed"
fi

# Install VS Code command line tools
if [[ "$INSTALL_VSCODE_CLI" == true ]]; then
    echo "⚙️ Installing VS Code CLI..."
    # The 'code' command should be available after installing VS Code via Homebrew
    # If not, we can add it manually
    sudo ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code 2>/dev/null || {
        echo "Please add VS Code CLI manually by opening VS Code and running 'Shell Command: Install code command in PATH'"
    }
    echo "✅ VS Code CLI installed"
fi

# Ghostty
if [[ "$INSTALL_GHOSTTY" == true ]]; then
    echo "👻 Installing Ghostty..."
    brew install --cask ghostty
    echo "✅ Ghostty installed"
fi

# Copy Ghostty config
if [[ "$COPY_GHOSTTY_CONFIG" == true ]]; then
    echo "👻 Copying Ghostty config..."
    # Get the directory where this script is located (dotfiles repo)
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    # Create ~/.config/ghostty directory if it doesn't exist
    mkdir -p ~/.config/ghostty

    # Copy the config file
    if [ -f "$SCRIPT_DIR/.config/ghostty/config" ]; then
        cp "$SCRIPT_DIR/.config/ghostty/config" ~/.config/ghostty/config
        echo "✅ Ghostty config copied to ~/.config/ghostty/config"
    else
        echo "⚠️  Ghostty config file not found in dotfiles"
    fi
fi

# AeroSpace
if [[ "$INSTALL_AEROSPACE" == true ]]; then
    echo "✈️  Installing AeroSpace..."
    brew install --cask nikitabobko/tap/aerospace
    echo "✅ AeroSpace installed"
fi

# Copy AeroSpace config
if [[ "$COPY_AEROSPACE_CONFIG" == true ]]; then
    echo "✈️  Copying AeroSpace config..."
    # Get the directory where this script is located (dotfiles repo)
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    # Create ~/.config/aerospace directory if it doesn't exist
    mkdir -p ~/.config/aerospace

    # Copy the config file
    if [ -f "$SCRIPT_DIR/.config/aerospace/aerospace.toml" ]; then
        cp "$SCRIPT_DIR/.config/aerospace/aerospace.toml" ~/.config/aerospace/aerospace.toml
        echo "✅ AeroSpace config copied to ~/.config/aerospace/aerospace.toml"
    else
        echo "⚠️  AeroSpace config file not found in dotfiles"
    fi
fi

# Google Chrome
if [[ "$INSTALL_GOOGLE_CHROME" == true ]]; then
    echo "🌐 Installing Google Chrome..."
    brew install --cask google-chrome
    echo "✅ Google Chrome installed"
fi

# Plex Media Server
if [[ "$INSTALL_PLEX" == true ]]; then
    echo "🎬 Installing Plex Media Server..."
    brew install --cask plex-media-server
    echo "✅ Plex Media Server installed"
fi

# Google Drive
if [[ "$INSTALL_GOOGLE_DRIVE" == true ]]; then
    echo "☁️  Installing Google Drive..."
    brew install --cask google-drive
    echo "✅ Google Drive installed"
fi

# Transmission
if [[ "$INSTALL_TRANSMISSION" == true ]]; then
    echo "📥 Installing Transmission (BitTorrent client)..."
    brew install --cask transmission
    echo "✅ Transmission installed"
fi

# Obsidian
if [[ "$INSTALL_OBSIDIAN" == true ]]; then
    echo "📝 Installing Obsidian..."
    brew install --cask obsidian
    echo "✅ Obsidian installed"
fi

# WhatsApp
if [[ "$INSTALL_WHATSAPP" == true ]]; then
    echo "💬 Installing WhatsApp..."
    brew install --cask whatsapp
    echo "✅ WhatsApp installed"
fi

# Spotify
if [[ "$INSTALL_SPOTIFY" == true ]]; then
    echo "🎵 Installing Spotify..."
    brew install --cask spotify
    echo "✅ Spotify installed"
fi

# Logi Options+
if [[ "$INSTALL_LOGI_OPTIONS" == true ]]; then
    echo "🖱️  Installing Logi Options+..."
    brew install --cask logi-options+
    echo "✅ Logi Options+ installed"
fi

# ChatGPT
if [[ "$INSTALL_CHATGPT" == true ]]; then
    echo "🤖 Installing ChatGPT..."
    brew install --cask chatgpt
    echo "✅ ChatGPT installed"
fi

# Android Platform Tools (ADB)
if [[ "$INSTALL_ADB" == true ]]; then
    echo "📱 Installing Android Platform Tools (ADB)..."
    brew install android-platform-tools
    echo "✅ Android Platform Tools (ADB) installed"
fi

# scrcpy
if [[ "$INSTALL_SCRCPY" == true ]]; then
    echo "📱 Installing scrcpy..."
    brew install scrcpy
    echo "✅ scrcpy installed"
fi

# borders
if [[ "$INSTALL_BORDERS" == true ]]; then
    echo "🔲 Installing borders..."
    brew tap FelixKratz/formulae
    brew install borders
    echo "✅ borders installed"
fi

# Shottr
if [[ "$INSTALL_SHOTTR" == true ]]; then
    echo "📸 Installing Shottr..."
    brew install --cask shottr
    echo "✅ Shottr installed"
fi

# Windows App
if [[ "$INSTALL_WINDOWS_APP" == true ]]; then
    echo "🪟 Installing Windows App..."
    brew install --cask windows-app
    echo "✅ Windows App installed"
fi

# MySQL (Server, Workbench, and Shell)
if [[ "$INSTALL_MYSQL" == true ]]; then
    echo "🗄️  Installing MySQL tools..."
    brew install mysql@8.4
    brew install --cask mysqlworkbench
    brew install --cask mysql-shell
    echo "✅ MySQL tools installed (Server 8.4, Workbench, Shell)"
    echo "📝 NOTE: Set MySQL root password with: mysql -u root -e \"ALTER USER 'root'@'localhost' IDENTIFIED BY 'G1234567';\""
fi

# Configure macOS settings
if [[ "$DISABLE_SPOTLIGHT" == true ]] || [[ "$MOVE_DOCK_LEFT" == true ]]; then
    echo ""
    echo "⚙️  Configuring macOS settings..."
fi

# Disable Spotlight keyboard shortcut
if [[ "$DISABLE_SPOTLIGHT" == true ]]; then
    echo "🔍 Disabling Spotlight keyboard shortcut..."
    # Disable Spotlight Show Finder search window (Cmd+Space)
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "{ enabled = 0; value = { parameters = (65535, 49, 1048576); type = 'standard'; }; }"
    echo "✅ Spotlight keyboard shortcut disabled (may require logout to take effect)"
fi

# Move Dock to left
if [[ "$MOVE_DOCK_LEFT" == true ]]; then
    echo "🪟 Moving Dock to left side..."
    defaults write com.apple.dock orientation left
    killall Dock
    echo "✅ Dock moved to left side"
fi

# Verify installations
echo ""
echo "🔍 Current installation status:"

command -v brew >/dev/null && echo "✅ Homebrew: $(brew --version | head -n1)"
command -v git >/dev/null && echo "✅ Git: $(git --version)"
command -v uv >/dev/null && echo "✅ uv: $(uv --version)"
command -v git-filter-repo >/dev/null && echo "✅ git-filter-repo: $(git-filter-repo --version 2>&1 | head -n1)"
command -v git-lfs >/dev/null && echo "✅ git-lfs: $(git-lfs --version | head -n1)"
command -v tmux >/dev/null && echo "✅ tmux: $(tmux -V)"
command -v nvim >/dev/null && echo "✅ Neovim: $(nvim --version | head -n1)"

# Check pyenv/Python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)" 2>/dev/null
eval "$(pyenv init -)" 2>/dev/null
command -v pyenv >/dev/null && echo "✅ pyenv: $(pyenv --version)"
command -v python >/dev/null && echo "✅ Python: $(python --version)"
command -v pip >/dev/null && echo "✅ pip: $(pip --version)"

# Check NVM/Node/npm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
command -v nvm >/dev/null && echo "✅ NVM: $(nvm --version)"
command -v node >/dev/null && echo "✅ Node.js: $(node --version)"
command -v npm >/dev/null && echo "✅ npm: $(npm --version)"
command -v claude >/dev/null && echo "✅ Claude Code CLI: $(claude --version 2>/dev/null | head -n1)"

ls /Applications/ 2>/dev/null | grep -qi "brave" && echo "✅ Brave Browser: Installed"
ls /Applications/ 2>/dev/null | grep -qi "lunar" && echo "✅ Lunar: Installed"
command -v maccy >/dev/null && echo "✅ Maccy: Installed"
ls /Applications/ 2>/dev/null | grep -qi "raycast" && echo "✅ Raycast: Installed"
ls /Applications/ 2>/dev/null | grep -qi "ghostty" && echo "✅ Ghostty: Installed"
ls /Applications/ 2>/dev/null | grep -qi "aerospace" && echo "✅ AeroSpace: Installed"
ls /Applications/ 2>/dev/null | grep -qi "google chrome" && echo "✅ Google Chrome: Installed"
ls /Applications/ 2>/dev/null | grep -qi "plex" && echo "✅ Plex Media Server: Installed"
ls /Applications/ 2>/dev/null | grep -qi "google drive" && echo "✅ Google Drive: Installed"
ls /Applications/ 2>/dev/null | grep -qi "transmission" && echo "✅ Transmission: Installed"
ls /Applications/ 2>/dev/null | grep -qi "obsidian" && echo "✅ Obsidian: Installed"
ls /Applications/ 2>/dev/null | grep -qi "whatsapp" && echo "✅ WhatsApp: Installed"
ls /Applications/ 2>/dev/null | grep -qi "spotify" && echo "✅ Spotify: Installed"
ls /Applications/ 2>/dev/null | grep -qi "logioptionsplus" && echo "✅ Logi Options+: Installed"
ls /Applications/ 2>/dev/null | grep -qi "chatgpt" && echo "✅ ChatGPT: Installed"
command -v adb >/dev/null && echo "✅ Android Platform Tools (ADB): $(adb --version | head -n1)"
command -v scrcpy >/dev/null && echo "✅ scrcpy: $(scrcpy --version 2>&1 | head -n1)"
command -v borders >/dev/null && echo "✅ borders: Installed"
ls /Applications/ 2>/dev/null | grep -qi "shottr" && echo "✅ Shottr: Installed"
ls /Applications/ 2>/dev/null | grep -qi "windows app" && echo "✅ Windows App: Installed"
command -v mysql >/dev/null && echo "✅ MySQL: $(mysql --version)"
ls /Applications/ 2>/dev/null | grep -qi "mysqlworkbench" && echo "✅ MySQL Workbench: Installed"
command -v mysqlsh >/dev/null && echo "✅ MySQL Shell: $(mysqlsh --version 2>&1 | head -n1)"
ls /Applications/ 2>/dev/null | grep -qi "visual studio code" && echo "✅ VS Code: Installed"
command -v code >/dev/null && echo "✅ VS Code CLI: Available"

echo ""
echo "🎉 macOS setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Restart your terminal or run 'source ~/.zshrc' to reload your shell"
if [[ "$DISABLE_SPOTLIGHT" == true ]]; then
    echo "2. Log out and log back in for Spotlight changes to fully apply"
    echo "3. Configure git if not already done:"
else
    echo "2. Configure git if not already done:"
fi
echo "   git config --global user.name 'Your Name'"
echo "   git config --global user.email 'your.email@example.com'"
if [[ "$INSTALL_MYSQL" == true ]]; then
    if [[ "$DISABLE_SPOTLIGHT" == true ]]; then
        echo "4. Set MySQL root password:"
        echo "   mysql -u root -e \"ALTER USER 'root'@'localhost' IDENTIFIED BY 'G1234567';\""
        echo "5. Open VS Code and install your preferred extensions"
    else
        echo "3. Set MySQL root password:"
        echo "   mysql -u root -e \"ALTER USER 'root'@'localhost' IDENTIFIED BY 'G1234567';\""
        echo "4. Open VS Code and install your preferred extensions"
    fi
else
    if [[ "$DISABLE_SPOTLIGHT" == true ]]; then
        echo "4. Open VS Code and install your preferred extensions"
    else
        echo "3. Open VS Code and install your preferred extensions"
    fi
fi
