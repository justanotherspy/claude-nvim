#!/bin/bash

# Neovim Configuration Installation Script

set -e

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

# Check for Node.js (required for many LSP servers)
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}⚠ Node.js not found. Installing...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt install -y nodejs
fi

# Check for Python3 and pip
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}⚠ Python3 not found. Installing...${NC}"
    sudo apt update && sudo apt install -y python3 python3-pip
fi

# Check for cargo (for Rust development)
if ! command -v cargo &> /dev/null; then
    echo -e "${YELLOW}⚠ Cargo not found. Install Rust for Rust development support.${NC}"
    echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
fi

# Install JetBrains Mono font
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

# Backup existing configuration
if [ -d "$HOME/.config/nvim" ]; then
    echo -e "\n${YELLOW}Backing up existing configuration...${NC}"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}✓ Backup created${NC}"
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
echo -e "\n${YELLOW}Installing plugins...${NC}"
nvim --headless "+Lazy! sync" +qa

echo -e "\n${GREEN}✅ Installation complete!${NC}"
echo -e "\nNext steps:"
echo -e "1. Open Neovim: ${YELLOW}nvim${NC}"
echo -e "2. Wait for plugins to install automatically"
echo -e "3. Run ${YELLOW}:checkhealth${NC} to verify setup"
echo -e "4. Read the usage guide: ${YELLOW}nvim ~/claude/nvim/USAGE_GUIDE.md${NC}"
echo -e "\n${GREEN}Happy coding! 🎉${NC}"