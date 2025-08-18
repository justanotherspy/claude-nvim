#!/bin/bash

# Neovim Configuration Installation Script

set -e

# Default values for flags
SKIP_FONTS=false
SKIP_DEPS=false
SKIP_NODE=false
SKIP_PYTHON=false
SKIP_RUST=false
SKIP_BACKUP=false
SKIP_PLUGINS=false
INSTALL_TMUX_CONFIG=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-fonts)
            SKIP_FONTS=true
            shift
            ;;
        --skip-deps)
            SKIP_DEPS=true
            shift
            ;;
        --skip-node)
            SKIP_NODE=true
            shift
            ;;
        --skip-python)
            SKIP_PYTHON=true
            shift
            ;;
        --skip-rust)
            SKIP_RUST=true
            shift
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --skip-plugins)
            SKIP_PLUGINS=true
            shift
            ;;
        --with-tmux)
            INSTALL_TMUX_CONFIG=true
            shift
            ;;
        --help|-h)
            echo "Neovim Configuration Installation Script"
            echo ""
            echo "Usage: ./install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-fonts      Skip JetBrains Mono font installation"
            echo "  --skip-deps       Skip all dependency installations (ripgrep, fd, fzf)"
            echo "  --skip-node       Skip Node.js installation"
            echo "  --skip-python     Skip Python3 installation"
            echo "  --skip-rust       Skip Rust/Cargo check"
            echo "  --skip-backup     Skip backing up existing configuration"
            echo "  --skip-plugins    Skip automatic plugin installation"
            echo "  --with-tmux       Install optimal tmux configuration"
            echo "  -h, --help        Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./install.sh                    # Full installation"
            echo "  ./install.sh --skip-fonts       # Install without fonts"
            echo "  ./install.sh --with-tmux        # Install with tmux config"
            echo "  ./install.sh --skip-deps --skip-fonts  # Minimal install"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "🚀 Installing Neovim Configuration..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Neovim is installed
if ! command -v nvim &> /dev/null; then
    echo -e "${RED}❌ Neovim is not installed!${NC}"
    echo "Please install Neovim first:"
    echo "  curl -LO https://github.com/neovim/neovim/releases/download/v0.10.3/nvim.appimage"
    echo "  chmod u+x nvim.appimage"
    echo "  sudo mv nvim.appimage /usr/local/bin/nvim"
    exit 1
fi

echo -e "${GREEN}✓ Neovim found: $(nvim --version | head -n1)${NC}"

# Check for required tools
echo -e "\n${YELLOW}Checking dependencies...${NC}"

# Check for git
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git is not installed!${NC}"
    echo "Installing git..."
    sudo apt update && sudo apt install -y git
fi

# Check for ripgrep (required for Telescope)
if [ "$SKIP_DEPS" = false ]; then
    if ! command -v rg &> /dev/null; then
        echo -e "${YELLOW}⚠ Ripgrep not found. Installing...${NC}"
        sudo apt update && sudo apt install -y ripgrep
    fi

    # Check for fd (optional but recommended for Telescope)
    if ! command -v fd &> /dev/null; then
        echo -e "${YELLOW}⚠ fd not found. Installing...${NC}"
        sudo apt update && sudo apt install -y fd-find
        # Create symlink for fd
        sudo ln -sf $(which fdfind) /usr/local/bin/fd 2>/dev/null || true
    fi

    # Check for fzf
    if ! command -v fzf &> /dev/null; then
        echo -e "${YELLOW}⚠ fzf not found. Installing...${NC}"
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all --no-bash --no-zsh --no-fish
        # Add to PATH for current session
        export PATH="$HOME/.fzf/bin:$PATH"
    fi
else
    echo -e "${YELLOW}⚠ Skipping dependency installation (--skip-deps)${NC}"
fi

# Check for Node.js (required for many LSP servers)
if [ "$SKIP_NODE" = false ]; then
    if ! command -v node &> /dev/null; then
        echo -e "${YELLOW}⚠ Node.js not found. Installing...${NC}"
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt install -y nodejs
    fi
else
    echo -e "${YELLOW}⚠ Skipping Node.js installation (--skip-node)${NC}"
fi

# Check for Python3 and pip
if [ "$SKIP_PYTHON" = false ]; then
    if ! command -v python3 &> /dev/null; then
        echo -e "${YELLOW}⚠ Python3 not found. Installing...${NC}"
        sudo apt update && sudo apt install -y python3 python3-pip
    fi
else
    echo -e "${YELLOW}⚠ Skipping Python3 installation (--skip-python)${NC}"
fi

# Check for cargo (for Rust development)
if [ "$SKIP_RUST" = false ]; then
    if ! command -v cargo &> /dev/null; then
        echo -e "${YELLOW}⚠ Cargo not found. Install Rust for Rust development support.${NC}"
        echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    fi
else
    echo -e "${YELLOW}⚠ Skipping Rust/Cargo check (--skip-rust)${NC}"
fi

# Install JetBrains Mono font
if [ "$SKIP_FONTS" = false ]; then
    echo -e "\n${YELLOW}Installing JetBrains Mono font...${NC}"
    if ! fc-list | grep -q "JetBrains Mono"; then
        wget -q --show-progress https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip -O /tmp/JetBrainsMono.zip
        sudo unzip -q /tmp/JetBrainsMono.zip -d /usr/share/fonts/
        sudo fc-cache -f -v > /dev/null 2>&1
        rm /tmp/JetBrainsMono.zip
        echo -e "${GREEN}✓ JetBrains Mono font installed${NC}"
    else
        echo -e "${GREEN}✓ JetBrains Mono font already installed${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Skipping font installation (--skip-fonts)${NC}"
fi

# Backup existing configuration
if [ "$SKIP_BACKUP" = false ]; then
    if [ -d "$HOME/.config/nvim" ]; then
        echo -e "\n${YELLOW}Backing up existing configuration...${NC}"
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${GREEN}✓ Backup created${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Skipping backup (--skip-backup)${NC}"
    if [ -d "$HOME/.config/nvim" ]; then
        echo -e "${RED}⚠ Warning: Existing configuration will be overwritten!${NC}"
        rm -rf "$HOME/.config/nvim"
    fi
fi

# Copy new configuration
echo -e "\n${YELLOW}Installing new configuration...${NC}"
mkdir -p "$HOME/.config/nvim"
cp -r ./* "$HOME/.config/nvim/"
echo -e "${GREEN}✓ Configuration files copied${NC}"

# Install lazy.nvim
echo -e "\n${YELLOW}Installing lazy.nvim plugin manager...${NC}"
git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable \
    "$HOME/.local/share/nvim/lazy/lazy.nvim" 2>/dev/null || true

# Install plugins
if [ "$SKIP_PLUGINS" = false ]; then
    echo -e "\n${YELLOW}Installing plugins...${NC}"
    nvim --headless "+Lazy! sync" +qa
else
    echo -e "${YELLOW}⚠ Skipping plugin installation (--skip-plugins)${NC}"
    echo -e "${YELLOW}Run :Lazy sync in Neovim to install plugins manually${NC}"
fi

# Install tmux configuration if requested
if [ "$INSTALL_TMUX_CONFIG" = true ]; then
    echo -e "\n${YELLOW}Installing tmux configuration...${NC}"
    
    # Check if tmux is installed
    if ! command -v tmux &> /dev/null; then
        echo -e "${YELLOW}⚠ Tmux not found. Installing...${NC}"
        sudo apt update && sudo apt install -y tmux
    fi
    
    # Backup existing tmux config
    if [ -f "$HOME/.tmux.conf" ]; then
        mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${GREEN}✓ Existing tmux config backed up${NC}"
    fi
    
    # Copy tmux configuration
    if [ -f "./tmux.conf" ]; then
        cp ./tmux.conf "$HOME/.tmux.conf"
        echo -e "${GREEN}✓ Tmux configuration installed${NC}"
    else
        echo -e "${RED}❌ tmux.conf not found in current directory${NC}"
    fi
fi

echo -e "\n${GREEN}✅ Installation complete!${NC}"
echo -e "\nNext steps:"
echo -e "1. Open Neovim: ${YELLOW}nvim${NC}"
if [ "$SKIP_PLUGINS" = false ]; then
    echo -e "2. Wait for plugins to install automatically"
else
    echo -e "2. Run ${YELLOW}:Lazy sync${NC} to install plugins"
fi
echo -e "3. Run ${YELLOW}:checkhealth${NC} to verify setup"
echo -e "4. Read the usage guide: ${YELLOW}nvim ~/claude/nvim/USAGE_GUIDE.md${NC}"
if [ "$INSTALL_TMUX_CONFIG" = true ]; then
    echo -e "5. Start tmux: ${YELLOW}tmux${NC} (config installed)"
fi
echo -e "\n${GREEN}Happy coding! 🎉${NC}"