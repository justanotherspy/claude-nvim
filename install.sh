#!/bin/bash

# Neovim Configuration Installation Script
# Idempotent installation with state management

set -e

# Load state management functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/state_manager.sh"

# Default values for flags
SKIP_FONTS=false
SKIP_DEPS=false
SKIP_NODE=false
SKIP_PYTHON=false
SKIP_RUST=false
SKIP_BACKUP=false
SKIP_PLUGINS=false
INSTALL_TMUX_CONFIG=false
SHOW_STATE=false
RESET_STATE=false

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
        --show-state)
            SHOW_STATE=true
            shift
            ;;
        --reset-state)
            RESET_STATE=true
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
            echo "  --show-state      Show current installation state and exit"
            echo "  --reset-state     Reset all installation states (for testing)"
            echo "  -h, --help        Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./install.sh                    # Full installation"
            echo "  ./install.sh --skip-fonts       # Install without fonts"
            echo "  ./install.sh --with-tmux        # Install with tmux config"
            echo "  ./install.sh --show-state       # Check installation status"
            echo "  ./install.sh --reset-state      # Reset state for fresh install"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Initialize state management
init_state

# Handle state commands
if [ "$SHOW_STATE" = true ]; then
    show_state
    exit 0
fi

if [ "$RESET_STATE" = true ]; then
    reset_state
    exit 0
fi

echo "🚀 Installing Neovim Configuration (Idempotent Mode)..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function for consistent output
log_action() {
    local component="$1"
    local action="$2"
    local status="$3"
    
    case "$status" in
        "skip")
            echo -e "${BLUE}⏸️  [$component] Skipped - $action${NC}"
            ;;
        "already")
            echo -e "${GREEN}✓ [$component] Already installed - $action${NC}"
            ;;
        "installing")
            echo -e "${YELLOW}⚙️  [$component] Installing - $action${NC}"
            ;;
        "success")
            echo -e "${GREEN}✅ [$component] Success - $action${NC}"
            ;;
        "failed")
            echo -e "${RED}❌ [$component] Failed - $action${NC}"
            ;;
    esac
}

# Check Neovim installation
check_neovim() {
    if needs_action "neovim_check"; then
        if check_and_update_state "neovim_check" "command -v nvim"; then
            log_action "Neovim" "Version: $(nvim --version | head -n1)" "already"
        else
            log_action "Neovim" "Not installed" "failed"
            echo -e "${RED}Please install Neovim first:${NC}"
            echo "  curl -LO https://github.com/neovim/neovim/releases/download/v0.10.3/nvim.appimage"
            echo "  chmod u+x nvim.appimage"
            echo "  sudo mv nvim.appimage /usr/local/bin/nvim"
            exit 1
        fi
    else
        log_action "Neovim" "Version check" "skip"
    fi
}

# Install Git
install_git() {
    if needs_action "git_install"; then
        if check_and_update_state "git_install" "command -v git"; then
            log_action "Git" "Already available" "already"
        else
            log_action "Git" "Installing via apt" "installing"
            if install_and_update_state "git_install" "sudo apt update && sudo apt install -y git" "command -v git"; then
                log_action "Git" "Installation completed" "success"
            else
                log_action "Git" "Installation failed" "failed"
                exit 1
            fi
        fi
    else
        log_action "Git" "Installation" "skip"
    fi
}

# Install dependencies
install_dependencies() {
    if [ "$SKIP_DEPS" = true ]; then
        log_action "Dependencies" "Skipped by user flag" "skip"
        return
    fi
    
    # Ripgrep
    if needs_action "ripgrep_install"; then
        if check_and_update_state "ripgrep_install" "command -v rg"; then
            log_action "Ripgrep" "Already available" "already"
        else
            log_action "Ripgrep" "Installing via apt" "installing"
            if install_and_update_state "ripgrep_install" "sudo apt update && sudo apt install -y ripgrep" "command -v rg"; then
                log_action "Ripgrep" "Installation completed" "success"
            else
                log_action "Ripgrep" "Installation failed" "failed"
            fi
        fi
    else
        log_action "Ripgrep" "Installation" "skip"
    fi
    
    # fd
    if needs_action "fd_install"; then
        if check_and_update_state "fd_install" "command -v fd"; then
            log_action "fd" "Already available" "already"
        else
            log_action "fd" "Installing via apt" "installing"
            install_cmd="sudo apt update && sudo apt install -y fd-find && sudo ln -sf \$(which fdfind) /usr/local/bin/fd 2>/dev/null || true"
            if install_and_update_state "fd_install" "$install_cmd" "command -v fd"; then
                log_action "fd" "Installation completed" "success"
            else
                log_action "fd" "Installation failed" "failed"
            fi
        fi
    else
        log_action "fd" "Installation" "skip"
    fi
    
    # fzf
    if needs_action "fzf_install"; then
        if check_and_update_state "fzf_install" "command -v fzf"; then
            log_action "fzf" "Already available" "already"
        else
            log_action "fzf" "Installing from source" "installing"
            install_cmd="git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all --no-bash --no-zsh --no-fish"
            if install_and_update_state "fzf_install" "$install_cmd" "command -v fzf || test -f ~/.fzf/bin/fzf"; then
                log_action "fzf" "Installation completed" "success"
                export PATH="$HOME/.fzf/bin:$PATH"
            else
                log_action "fzf" "Installation failed" "failed"
            fi
        fi
    else
        log_action "fzf" "Installation" "skip"
    fi
}

# Install Node.js
install_node() {
    if [ "$SKIP_NODE" = true ]; then
        log_action "Node.js" "Skipped by user flag" "skip"
        return
    fi
    
    if needs_action "node_install"; then
        if check_and_update_state "node_install" "command -v node"; then
            log_action "Node.js" "Already available" "already"
        else
            log_action "Node.js" "Installing LTS version" "installing"
            install_cmd="curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt install -y nodejs"
            if install_and_update_state "node_install" "$install_cmd" "command -v node"; then
                log_action "Node.js" "Installation completed" "success"
            else
                log_action "Node.js" "Installation failed" "failed"
            fi
        fi
    else
        log_action "Node.js" "Installation" "skip"
    fi
}

# Install Python3
install_python() {
    if [ "$SKIP_PYTHON" = true ]; then
        log_action "Python3" "Skipped by user flag" "skip"
        return
    fi
    
    if needs_action "python_install"; then
        if check_and_update_state "python_install" "command -v python3"; then
            log_action "Python3" "Already available" "already"
        else
            log_action "Python3" "Installing via apt" "installing"
            if install_and_update_state "python_install" "sudo apt update && sudo apt install -y python3 python3-pip" "command -v python3"; then
                log_action "Python3" "Installation completed" "success"
            else
                log_action "Python3" "Installation failed" "failed"
            fi
        fi
    else
        log_action "Python3" "Installation" "skip"
    fi
}

# Install JetBrains Mono font
install_fonts() {
    if [ "$SKIP_FONTS" = true ]; then
        log_action "JetBrains Mono" "Skipped by user flag" "skip"
        return
    fi
    
    if needs_action "fonts_install"; then
        if check_and_update_state "fonts_install" "fc-list | grep -q 'JetBrains Mono'"; then
            log_action "JetBrains Mono" "Already installed" "already"
        else
            log_action "JetBrains Mono" "Downloading and installing" "installing"
            install_cmd="wget -q --show-progress https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip -O /tmp/JetBrainsMono.zip && sudo unzip -q /tmp/JetBrainsMono.zip -d /usr/share/fonts/ && sudo fc-cache -f -v > /dev/null 2>&1 && rm /tmp/JetBrainsMono.zip"
            if install_and_update_state "fonts_install" "$install_cmd" "fc-list | grep -q 'JetBrains Mono'"; then
                log_action "JetBrains Mono" "Installation completed" "success"
            else
                log_action "JetBrains Mono" "Installation failed" "failed"
            fi
        fi
    else
        log_action "JetBrains Mono" "Installation" "skip"
    fi
}

# Backup existing configuration
backup_config() {
    if [ "$SKIP_BACKUP" = true ]; then
        log_action "Config Backup" "Skipped by user flag" "skip"
        # Still remove existing config if present
        if [ -d "$HOME/.config/nvim" ]; then
            log_action "Config Cleanup" "Removing existing config" "installing"
            rm -rf "$HOME/.config/nvim"
        fi
        return
    fi
    
    if needs_action "config_backup"; then
        if [ -d "$HOME/.config/nvim" ]; then
            log_action "Config Backup" "Creating backup" "installing"
            backup_name="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
            if mv "$HOME/.config/nvim" "$backup_name"; then
                set_state "config_backup" "installed"
                log_action "Config Backup" "Backup created: $(basename $backup_name)" "success"
            else
                set_state "config_backup" "notinstalled"
                log_action "Config Backup" "Backup failed" "failed"
            fi
        else
            set_state "config_backup" "installed"
            log_action "Config Backup" "No existing config found" "already"
        fi
    else
        log_action "Config Backup" "Already handled" "skip"
    fi
}

# Install new configuration
install_config() {
    if needs_action "config_install"; then
        if [ -d "$HOME/.config/nvim" ] && [ -f "$HOME/.config/nvim/init.lua" ]; then
            set_state "config_install" "installed"
            log_action "Config Install" "Already installed" "already"
        else
            log_action "Config Install" "Copying configuration files" "installing"
            if mkdir -p "$HOME/.config/nvim" && cp -r ./* "$HOME/.config/nvim/"; then
                set_state "config_install" "installed"
                log_action "Config Install" "Configuration files copied" "success"
            else
                set_state "config_install" "notinstalled"
                log_action "Config Install" "Copy failed" "failed"
            fi
        fi
    else
        log_action "Config Install" "Already installed" "skip"
    fi
}

# Install lazy.nvim
install_lazyvim() {
    if needs_action "lazyvim_install"; then
        lazy_path="$HOME/.local/share/nvim/lazy/lazy.nvim"
        if [ -d "$lazy_path" ]; then
            set_state "lazyvim_install" "installed"
            log_action "Lazy.nvim" "Already installed" "already"
        else
            log_action "Lazy.nvim" "Cloning plugin manager" "installing"
            install_cmd="git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable '$lazy_path'"
            if eval "$install_cmd" 2>/dev/null; then
                set_state "lazyvim_install" "installed"
                log_action "Lazy.nvim" "Plugin manager installed" "success"
            else
                set_state "lazyvim_install" "notinstalled"
                log_action "Lazy.nvim" "Installation failed" "failed"
            fi
        fi
    else
        log_action "Lazy.nvim" "Already installed" "skip"
    fi
}

# Install plugins
install_plugins() {
    if [ "$SKIP_PLUGINS" = true ]; then
        log_action "Plugins" "Skipped by user flag" "skip"
        return
    fi
    
    if needs_action "plugins_install"; then
        log_action "Plugins" "Installing via Lazy.nvim" "installing"
        if nvim --headless "+Lazy! sync" +qa 2>/dev/null; then
            set_state "plugins_install" "installed"
            log_action "Plugins" "Plugin installation completed" "success"
        else
            set_state "plugins_install" "notinstalled"
            log_action "Plugins" "Plugin installation failed" "failed"
        fi
    else
        log_action "Plugins" "Already installed" "skip"
    fi
}

# Install tmux configuration
install_tmux() {
    if [ "$INSTALL_TMUX_CONFIG" = false ]; then
        log_action "Tmux" "Not requested" "skip"
        return
    fi
    
    if needs_action "tmux_install"; then
        # Check if tmux is installed
        if ! command -v tmux &> /dev/null; then
            log_action "Tmux" "Installing tmux binary" "installing"
            sudo apt update && sudo apt install -y tmux
        fi
        
        # Check if our config is already installed
        if [ -f "$HOME/.tmux.conf" ] && grep -q "Claude Neovim" "$HOME/.tmux.conf" 2>/dev/null; then
            set_state "tmux_install" "installed"
            log_action "Tmux" "Configuration already installed" "already"
        else
            log_action "Tmux" "Installing configuration" "installing"
            
            # Backup existing config
            if [ -f "$HOME/.tmux.conf" ]; then
                mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            
            # Install new config
            if [ -f "./tmux.conf" ] && cp ./tmux.conf "$HOME/.tmux.conf"; then
                set_state "tmux_install" "installed"
                log_action "Tmux" "Configuration installed" "success"
            else
                set_state "tmux_install" "notinstalled"
                log_action "Tmux" "Configuration installation failed" "failed"
            fi
        fi
    else
        log_action "Tmux" "Already configured" "skip"
    fi
}

# Main installation flow
main() {
    echo -e "\n${YELLOW}Checking installation state...${NC}"
    
    check_neovim
    install_git
    install_dependencies
    install_node
    install_python
    install_fonts
    backup_config
    install_config
    install_lazyvim
    install_plugins
    install_tmux
    
    echo -e "\n${GREEN}✅ Installation process complete!${NC}"
    echo -e "\n${BLUE}Installation Summary:${NC}"
    show_state
    
    echo -e "\n${GREEN}Next steps:${NC}"
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
    echo -e "\n${BLUE}💡 Tip: Run './install.sh --show-state' to check installation status anytime${NC}"
}

# Run main installation
main