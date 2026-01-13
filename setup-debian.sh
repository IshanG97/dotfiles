#!/bin/bash

set -e

echo "🚀 Starting Debian setup..."

# Check if running on Debian/Ubuntu
if [[ ! -f /etc/debian_version ]]; then
    echo "❌ This script is only for Debian-based systems"
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
CONFIGURE_SUDO=false
INSTALL_BUILD_ESSENTIAL=false
INSTALL_CURL=false
INSTALL_GIT=false
INSTALL_UV=false
INSTALL_GIT_FILTER_REPO=false
INSTALL_GIT_LFS=false
INSTALL_TMUX=false
INSTALL_OPENSSH_SERVER=false
INSTALL_BRAVE=false
INSTALL_VSCODE=false
INSTALL_NVM=false
INSTALL_NODE=false
INSTALL_CLAUDE_CODE=false
INSTALL_PYENV=false
INSTALL_PYTHON=false
INSTALL_GOOGLE_CHROME=false
INSTALL_TRANSMISSION=false
INSTALL_OBSIDIAN=false
INSTALL_SPOTIFY=false
INSTALL_ADB=false
INSTALL_SCRCPY=false
INSTALL_FLAMESHOT=false
INSTALL_I3=false
INSTALL_POLYBAR=false
INSTALL_ROFI=false
INSTALL_PICOM=false
INSTALL_FLATPAK=false
INSTALL_WHATSAPP=false
INSTALL_RCLONE=false
INSTALL_PLEX=false
INSTALL_COPYQ=false
INSTALL_REMMINA=false
INSTALL_WINE=false

# Check if current user needs sudo configuration
CURRENT_USER=$(whoami)
if ! sudo -l &>/dev/null 2>&1 || ! sudo -n true 2>/dev/null; then
    if prompt_yes_no "🔐 Configure sudo access for user '$CURRENT_USER'?"; then
        CONFIGURE_SUDO=true
    fi
else
    echo "✅ User '$CURRENT_USER' already has sudo access"
fi

# Check build-essential
if ! dpkg -l | grep -q "^ii  build-essential"; then
    if prompt_yes_no "🔧 Install build-essential (compiler and build tools)?"; then
        INSTALL_BUILD_ESSENTIAL=true
    fi
else
    echo "✅ build-essential already installed"
fi

# Check curl
if ! command -v curl &>/dev/null; then
    if prompt_yes_no "📡 Install curl?"; then
        INSTALL_CURL=true
    fi
else
    echo "✅ curl already installed"
fi

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

# Check openssh-server
if ! systemctl is-enabled ssh &>/dev/null && ! systemctl is-enabled sshd &>/dev/null; then
    if prompt_yes_no "🔐 Install OpenSSH Server (for remote SSH access)?"; then
        INSTALL_OPENSSH_SERVER=true
    fi
else
    echo "✅ OpenSSH Server already installed"
fi

# Check uv
if ! command -v uv &>/dev/null; then
    if prompt_yes_no "🐍 Install uv (Python package manager)?"; then
        INSTALL_UV=true
    fi
else
    echo "✅ uv already installed"
fi

# Check NVM
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

# Check Flatpak
if ! command -v flatpak &>/dev/null; then
    if prompt_yes_no "📦 Install Flatpak (universal package manager)?"; then
        INSTALL_FLATPAK=true
    fi
else
    echo "✅ Flatpak already installed"
fi

# GUI Applications
if command -v dpkg &>/dev/null; then
    # Check Brave Browser
    if ! command -v brave-browser &>/dev/null && ! dpkg -l | grep -q brave-browser; then
        if prompt_yes_no "🦁 Install Brave Browser?"; then
            INSTALL_BRAVE=true
        fi
    else
        echo "✅ Brave Browser already installed"
    fi

    # Check Google Chrome
    if ! command -v google-chrome &>/dev/null && ! dpkg -l | grep -q google-chrome; then
        if prompt_yes_no "🌐 Install Google Chrome?"; then
            INSTALL_GOOGLE_CHROME=true
        fi
    else
        echo "✅ Google Chrome already installed"
    fi

    # Check Visual Studio Code
    if ! command -v code &>/dev/null && ! dpkg -l | grep -q "^ii  code"; then
        if prompt_yes_no "💻 Install Visual Studio Code?"; then
            INSTALL_VSCODE=true
        fi
    else
        echo "✅ Visual Studio Code already installed"
    fi

    # Check Transmission
    if ! command -v transmission-gtk &>/dev/null; then
        if prompt_yes_no "📥 Install Transmission (BitTorrent client)?"; then
            INSTALL_TRANSMISSION=true
        fi
    else
        echo "✅ Transmission already installed"
    fi

    # Check Obsidian (via Flatpak or AppImage)
    if ! command -v obsidian &>/dev/null && ! flatpak list 2>/dev/null | grep -q obsidian; then
        if prompt_yes_no "📝 Install Obsidian (note-taking app)?"; then
            INSTALL_OBSIDIAN=true
        fi
    else
        echo "✅ Obsidian already installed"
    fi

    # Check Spotify
    if ! command -v spotify &>/dev/null && ! dpkg -l | grep -q spotify-client; then
        if prompt_yes_no "🎵 Install Spotify?"; then
            INSTALL_SPOTIFY=true
        fi
    else
        echo "✅ Spotify already installed"
    fi

    # Check ADB
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

    # Check Flameshot
    if ! command -v flameshot &>/dev/null; then
        if prompt_yes_no "📸 Install Flameshot (screenshot tool)?"; then
            INSTALL_FLAMESHOT=true
        fi
    else
        echo "✅ Flameshot already installed"
    fi

    # Check i3 window manager
    if ! command -v i3 &>/dev/null; then
        if prompt_yes_no "🪟 Install i3 (tiling window manager)?"; then
            INSTALL_I3=true
            # Ask about related tools if installing i3
            if ! command -v polybar &>/dev/null; then
                if prompt_yes_no "   Install Polybar (status bar for i3)?"; then
                    INSTALL_POLYBAR=true
                fi
            fi
            if ! command -v rofi &>/dev/null; then
                if prompt_yes_no "   Install Rofi (application launcher)?"; then
                    INSTALL_ROFI=true
                fi
            fi
            if ! command -v picom &>/dev/null; then
                if prompt_yes_no "   Install Picom (compositor for transparency/effects)?"; then
                    INSTALL_PICOM=true
                fi
            fi
        fi
    else
        echo "✅ i3 already installed"
        # Check related tools separately if i3 exists
        if ! command -v polybar &>/dev/null; then
            if prompt_yes_no "📊 Install Polybar (status bar)?"; then
                INSTALL_POLYBAR=true
            fi
        else
            echo "✅ Polybar already installed"
        fi

        if ! command -v rofi &>/dev/null; then
            if prompt_yes_no "🔍 Install Rofi (application launcher)?"; then
                INSTALL_ROFI=true
            fi
        else
            echo "✅ Rofi already installed"
        fi

        if ! command -v picom &>/dev/null; then
            if prompt_yes_no "✨ Install Picom (compositor)?"; then
                INSTALL_PICOM=true
            fi
        else
            echo "✅ Picom already installed"
        fi
    fi

    # Check WhatsApp (via Flatpak)
    if ! flatpak list 2>/dev/null | grep -q whatsapp; then
        if prompt_yes_no "💬 Install WhatsApp (unofficial client via Flatpak)?"; then
            INSTALL_WHATSAPP=true
        fi
    else
        echo "✅ WhatsApp already installed"
    fi

    # Check rclone (Google Drive alternative)
    if ! command -v rclone &>/dev/null; then
        if prompt_yes_no "☁️  Install rclone (cloud storage sync tool - supports Google Drive)?"; then
            INSTALL_RCLONE=true
        fi
    else
        echo "✅ rclone already installed"
    fi

    # Check Plex Media Server
    if ! command -v plexmediaserver &>/dev/null && ! dpkg -l | grep -q plexmediaserver; then
        if prompt_yes_no "🎬 Install Plex Media Server?"; then
            INSTALL_PLEX=true
        fi
    else
        echo "✅ Plex Media Server already installed"
    fi

    # Check CopyQ (clipboard manager - Maccy alternative)
    if ! command -v copyq &>/dev/null; then
        if prompt_yes_no "📋 Install CopyQ (clipboard manager)?"; then
            INSTALL_COPYQ=true
        fi
    else
        echo "✅ CopyQ already installed"
    fi

    # Check Remmina (Remote Desktop - Windows App alternative)
    if ! command -v remmina &>/dev/null; then
        if prompt_yes_no "🪟 Install Remmina (Remote Desktop client)?"; then
            INSTALL_REMMINA=true
        fi
    else
        echo "✅ Remmina already installed"
    fi

    # Check Wine
    if ! command -v wine &>/dev/null; then
        if prompt_yes_no "🍷 Install Wine (Windows compatibility layer)?"; then
            INSTALL_WINE=true
        fi
    else
        echo "✅ Wine already installed"
    fi
fi

echo ""
echo "🚦 Starting installation based on your choices..."
echo ""

# Configure sudo access for current user
if [[ "$CONFIGURE_SUDO" == true ]]; then
    echo "🔐 Configuring sudo access for user '$CURRENT_USER'..."

    # Add user to sudo group
    sudo usermod -aG sudo "$CURRENT_USER"

    # Create sudoers file for the user
    echo "$CURRENT_USER ALL=(ALL:ALL) ALL" | sudo tee /etc/sudoers.d/"$CURRENT_USER" > /dev/null

    # Set sudo timestamp timeout
    echo "Defaults        timestamp_timeout=30" | sudo tee /etc/sudoers.d/timestamp_timeout > /dev/null
    sudo chmod 0440 /etc/sudoers.d/timestamp_timeout

    # Set proper permissions
    sudo chmod 0440 /etc/sudoers.d/"$CURRENT_USER"

    # Verify sudoers configuration
    if sudo visudo -c &>/dev/null; then
        echo "✅ Sudo access configured for user '$CURRENT_USER'"
        echo "ℹ️  Note: You may need to log out and log back in for group membership to take full effect"
    else
        echo "❌ Error: sudoers configuration failed"
        sudo rm -f /etc/sudoers.d/"$CURRENT_USER"
        exit 1
    fi
fi

# Update package list
echo "📦 Updating package list..."
sudo apt update

# Install build-essential
if [[ "$INSTALL_BUILD_ESSENTIAL" == true ]]; then
    echo "🔧 Installing build-essential..."
    sudo apt install -y build-essential
    echo "✅ build-essential installed"
fi

# Install curl
if [[ "$INSTALL_CURL" == true ]]; then
    echo "📡 Installing curl..."
    sudo apt install -y curl
    echo "✅ curl installed"
fi

# Install git
if [[ "$INSTALL_GIT" == true ]]; then
    echo "📚 Installing Git..."
    sudo apt install -y git
    echo "✅ Git installed"
fi

# Install git-filter-repo
if [[ "$INSTALL_GIT_FILTER_REPO" == true ]]; then
    echo "🧹 Installing git-filter-repo..."
    sudo apt install -y git-filter-repo
    echo "✅ git-filter-repo installed"
fi

# Install git-lfs
if [[ "$INSTALL_GIT_LFS" == true ]]; then
    echo "📦 Installing git-lfs..."
    sudo apt install -y git-lfs
    git lfs install
    echo "✅ git-lfs installed"
fi

# Install tmux
if [[ "$INSTALL_TMUX" == true ]]; then
    echo "💻 Installing tmux..."
    sudo apt install -y tmux
    echo "✅ tmux installed"
fi

# Install OpenSSH Server
if [[ "$INSTALL_OPENSSH_SERVER" == true ]]; then
    echo "🔐 Installing OpenSSH Server..."
    sudo apt install -y openssh-server
    sudo systemctl enable ssh
    sudo systemctl start ssh
    echo "✅ OpenSSH Server installed and started"
fi

# Install uv
if [[ "$INSTALL_UV" == true ]]; then
    echo "🐍 Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add uv to PATH in .bashrc and .zshrc if they exist
    export PATH="$HOME/.cargo/bin:$PATH"
    if [ -f "$HOME/.bashrc" ]; then
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
    fi
    if [ -f "$HOME/.zshrc" ]; then
        echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.zshrc
    fi
    echo "✅ uv installed"
fi

# Install pyenv dependencies and pyenv
if [[ "$INSTALL_PYENV" == true ]]; then
    echo "🐍 Installing pyenv dependencies..."
    sudo apt install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev

    echo "🐍 Installing pyenv..."
    curl https://pyenv.run | bash

    # Add pyenv to shell config files
    PYENV_CONFIG='
# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"'

    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q 'eval "$(pyenv init -)"' ~/.bashrc 2>/dev/null; then
            echo "$PYENV_CONFIG" >> ~/.bashrc
        fi
    fi

    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'eval "$(pyenv init -)"' ~/.zshrc 2>/dev/null; then
            echo "$PYENV_CONFIG" >> ~/.zshrc
        fi
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

# Install Flatpak
if [[ "$INSTALL_FLATPAK" == true ]]; then
    echo "📦 Installing Flatpak..."
    sudo apt install -y flatpak
    # Add Flathub repository
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "✅ Flatpak installed"
fi

# Install GUI applications
# Brave Browser
if [[ "$INSTALL_BRAVE" == true ]]; then
    echo "🦁 Installing Brave Browser..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt update
    sudo apt install -y brave-browser
    echo "✅ Brave Browser installed"
fi

# Google Chrome
if [[ "$INSTALL_GOOGLE_CHROME" == true ]]; then
    echo "🌐 Installing Google Chrome..."
    sudo wget -q -O /etc/apt/keyrings/linux_signing_key.pub https://dl-ssl.google.com/linux/linux_signing_key.pub
    sudo tee /etc/apt/sources.list.d/google-chrome.sources > /dev/null <<'EOF'
Types: deb
URIs: http://dl.google.com/linux/chrome/deb/
Suites: stable
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/linux_signing_key.pub
EOF
    sudo apt update
    sudo apt install -y google-chrome-stable
    echo "✅ Google Chrome installed"
fi

# Visual Studio Code
if [[ "$INSTALL_VSCODE" == true ]]; then
    echo "💻 Installing Visual Studio Code..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm /tmp/packages.microsoft.gpg
    sudo apt update
    sudo apt install -y code
    echo "✅ Visual Studio Code installed"
fi

# Transmission
if [[ "$INSTALL_TRANSMISSION" == true ]]; then
    echo "📥 Installing Transmission..."
    sudo apt install -y transmission-gtk
    echo "✅ Transmission installed"
fi

# Obsidian (via Flatpak)
if [[ "$INSTALL_OBSIDIAN" == true ]]; then
    if command -v flatpak &>/dev/null; then
        echo "📝 Installing Obsidian via Flatpak..."
        flatpak install -y flathub md.obsidian.Obsidian
        echo "✅ Obsidian installed"
    else
        echo "⚠️  Flatpak not available. Install Flatpak first or download Obsidian AppImage manually."
    fi
fi

# Spotify
if [[ "$INSTALL_SPOTIFY" == true ]]; then
    echo "🎵 Installing Spotify..."
    curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo apt update
    sudo apt install -y spotify-client
    echo "✅ Spotify installed"
fi

# Android Platform Tools (ADB)
if [[ "$INSTALL_ADB" == true ]]; then
    echo "📱 Installing Android Platform Tools (ADB)..."
    sudo apt install -y android-tools-adb android-tools-fastboot
    echo "✅ Android Platform Tools (ADB) installed"
fi

# scrcpy
if [[ "$INSTALL_SCRCPY" == true ]]; then
    echo "📱 Installing scrcpy..."
    sudo apt install -y scrcpy
    echo "✅ scrcpy installed"
fi

# Flameshot
if [[ "$INSTALL_FLAMESHOT" == true ]]; then
    echo "📸 Installing Flameshot..."
    sudo apt install -y flameshot
    echo "✅ Flameshot installed"
fi

# i3 window manager and related tools
if [[ "$INSTALL_I3" == true ]]; then
    echo "🪟 Installing i3 window manager..."
    sudo apt install -y i3
    echo "✅ i3 installed"
fi

# Polybar (install after i3 if needed)
if [[ "$INSTALL_POLYBAR" == true ]]; then
    echo "📊 Installing Polybar..."
    sudo apt install -y polybar
    echo "✅ Polybar installed"
fi

# Rofi
if [[ "$INSTALL_ROFI" == true ]]; then
    echo "🔍 Installing Rofi..."
    sudo apt install -y rofi
    echo "✅ Rofi installed"
fi

# Picom
if [[ "$INSTALL_PICOM" == true ]]; then
    echo "✨ Installing Picom..."
    sudo apt install -y picom
    echo "✅ Picom installed"
fi

# WhatsApp (via Flatpak)
if [[ "$INSTALL_WHATSAPP" == true ]]; then
    if command -v flatpak &>/dev/null; then
        echo "💬 Installing WhatsApp via Flatpak..."
        flatpak install -y flathub io.github.mimbrero.WhatsAppDesktop
        echo "✅ WhatsApp installed"
    else
        echo "⚠️  Flatpak not available. Install Flatpak first."
    fi
fi

# rclone
if [[ "$INSTALL_RCLONE" == true ]]; then
    echo "☁️  Installing rclone..."
    sudo apt install -y rclone
    echo "✅ rclone installed"
    echo "ℹ️  Run 'rclone config' to set up cloud storage providers"
fi

# Plex Media Server
if [[ "$INSTALL_PLEX" == true ]]; then
    echo "🎬 Installing Plex Media Server..."
    # Download and install Plex
    wget -O /tmp/plexmediaserver.deb https://downloads.plex.tv/plex-media-server-new/1.40.1.8227-c0dd5a73e/debian/plexmediaserver_1.40.1.8227-c0dd5a73e_amd64.deb
    sudo apt install -y /tmp/plexmediaserver.deb
    rm /tmp/plexmediaserver.deb
    echo "✅ Plex Media Server installed"
    echo "ℹ️  Access Plex at http://localhost:32400/web"
fi

# CopyQ (clipboard manager)
if [[ "$INSTALL_COPYQ" == true ]]; then
    echo "📋 Installing CopyQ..."
    sudo apt install -y copyq
    echo "✅ CopyQ installed"
fi

# Remmina (Remote Desktop)
if [[ "$INSTALL_REMMINA" == true ]]; then
    echo "🪟 Installing Remmina..."
    sudo apt install -y remmina remmina-plugin-rdp remmina-plugin-vnc
    echo "✅ Remmina installed"
fi

# Wine (Windows compatibility layer)
if [[ "$INSTALL_WINE" == true ]]; then
    echo "🍷 Installing Wine..."

    # Enable 32-bit architecture
    sudo dpkg --add-architecture i386

    # Create keyrings directory
    sudo mkdir -pm755 /etc/apt/keyrings

    # Add Wine repository key
    wget -O - https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -

    # Add Wine repository
    sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/trixie/winehq-trixie.sources

    # Update and install Wine
    sudo apt update
    sudo apt install -y --install-recommends winehq-stable

    echo "✅ Wine installed"
fi

# Verify installations
echo ""
echo "🔍 Current installation status:"

command -v curl >/dev/null && echo "✅ curl: $(curl --version | head -n1)"
command -v git >/dev/null && echo "✅ Git: $(git --version)"
command -v uv >/dev/null && echo "✅ uv: $(uv --version)"
command -v git-filter-repo >/dev/null && echo "✅ git-filter-repo: $(git-filter-repo --version 2>&1 | head -n1)"
command -v git-lfs >/dev/null && echo "✅ git-lfs: $(git-lfs --version | head -n1)"
command -v tmux >/dev/null && echo "✅ tmux: $(tmux -V)"
if systemctl is-active --quiet ssh || systemctl is-active --quiet sshd; then
    echo "✅ OpenSSH Server: Running"
fi

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

command -v flatpak >/dev/null && echo "✅ Flatpak: $(flatpak --version)"
command -v brave-browser >/dev/null && echo "✅ Brave Browser: Installed"
command -v google-chrome >/dev/null && echo "✅ Google Chrome: Installed"
command -v code >/dev/null && echo "✅ VS Code: Installed"
command -v transmission-gtk >/dev/null && echo "✅ Transmission: Installed"
flatpak list 2>/dev/null | grep -q obsidian && echo "✅ Obsidian: Installed"
command -v spotify >/dev/null && echo "✅ Spotify: Installed"
command -v adb >/dev/null && echo "✅ Android Platform Tools (ADB): $(adb --version | head -n1)"
command -v scrcpy >/dev/null && echo "✅ scrcpy: $(scrcpy --version 2>&1 | head -n1)"
command -v flameshot >/dev/null && echo "✅ Flameshot: Installed"
command -v i3 >/dev/null && echo "✅ i3: $(i3 --version | head -n1)"
command -v polybar >/dev/null && echo "✅ Polybar: $(polybar --version | head -n1)"
command -v rofi >/dev/null && echo "✅ Rofi: $(rofi -version | head -n1)"
command -v picom >/dev/null && echo "✅ Picom: $(picom --version 2>&1 | head -n1)"
flatpak list 2>/dev/null | grep -q whatsapp && echo "✅ WhatsApp: Installed"
command -v rclone >/dev/null && echo "✅ rclone: $(rclone --version | head -n1)"
dpkg -l 2>/dev/null | grep -q plexmediaserver && echo "✅ Plex Media Server: Installed"
command -v copyq >/dev/null && echo "✅ CopyQ: Installed"
command -v remmina >/dev/null && echo "✅ Remmina: Installed"

echo ""
echo "🎉 Debian setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Restart your terminal or run 'source ~/.bashrc' (or ~/.zshrc) to reload your shell"
echo "2. Configure git if not already done:"
echo "   git config --global user.name 'Your Name'"
echo "   git config --global user.email 'your.email@example.com'"
echo "3. Open VS Code and install your preferred extensions"
if [[ "$INSTALL_I3" == true ]]; then
    echo "4. Log out and select i3 from your login manager to start using i3"
fi
