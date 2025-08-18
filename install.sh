#!/bin/bash

# Neovim Configuration Installation Script
# Idempotent installation with state management
# Cross-platform support: Linux and macOS

set -e

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

# Set OS-specific variables
OS_TYPE=$(detect_os)
if [[ "$OS_TYPE" == "unsupported" ]]; then
    echo "❌ Error: Unsupported operating system. This script supports Linux and macOS only."
    exit 1
fi

echo "🔍 Detected OS: $OS_TYPE"

# Load state management functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/state_manager.sh"

# Default values for flags
SKIP_FONTS=false
SKIP_DEPS=false
SKIP_NODE=false
SKIP_PYTHON=false
SKIP_BACKUP=false
SKIP_PLUGINS=false
SKIP_TMUX=false
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
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --skip-plugins)
            SKIP_PLUGINS=true
            shift
            ;;
        --skip-tmux)
            SKIP_TMUX=true
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
            echo "  --skip-backup     Skip backing up existing configuration"
            echo "  --skip-plugins    Skip automatic plugin installation"
            echo "  --skip-tmux       Skip tmux installation and configuration"
            echo "  --show-state      Show current installation state and exit"
            echo "  --reset-state     Reset all installation states (for testing)"
            echo "  -h, --help        Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./install.sh                    # Full installation with tmux"
            echo "  ./install.sh --skip-fonts       # Install without fonts"
            echo "  ./install.sh --skip-tmux        # Install without tmux configuration"
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

# Track whether package manager update has been run to prevent conflicts
PKG_UPDATE_DONE=false

# Cross-platform package manager update function
ensure_package_manager_updated() {
    if [ "$PKG_UPDATE_DONE" = false ]; then
        case "$OS_TYPE" in
            "linux")
                log_action "System" "Updating apt package lists" "installing"
                
                # Retry apt update up to 2 times for network issues
                local retry_count=0
                local max_retries=2
                
                while [ $retry_count -le $max_retries ]; do
                    if sudo apt update; then
                        PKG_UPDATE_DONE=true
                        log_action "System" "Package lists updated" "success"
                        return 0
                    else
                        retry_count=$((retry_count + 1))
                        if [ $retry_count -le $max_retries ]; then
                            log_action "System" "Retrying apt update ($retry_count/$max_retries)" "installing"
                            sleep 2
                        fi
                    fi
                done
                
                log_action "System" "Package list update failed after $max_retries attempts" "failed"
                echo -e "${YELLOW}Warning: apt update failed. Individual package installs may fail.${NC}"
                PKG_UPDATE_DONE=true  # Set to true to avoid repeated attempts
                ;;
            "macos")
                log_action "System" "Updating Homebrew" "installing"
                
                # Ensure Homebrew is installed and properly configured
                if ! ensure_homebrew_installed; then
                    log_action "Homebrew" "Failed to install or configure Homebrew" "failed"
                    return 1
                fi
                
                # Update Homebrew
                if brew update; then
                    PKG_UPDATE_DONE=true
                    log_action "System" "Homebrew updated" "success"
                    return 0
                else
                    log_action "System" "Homebrew update failed" "failed"
                    echo -e "${YELLOW}Warning: brew update failed. Individual package installs may fail.${NC}"
                    PKG_UPDATE_DONE=true
                fi
                ;;
        esac
    fi
}

# Ensure Homebrew is installed and properly configured (macOS only)
ensure_homebrew_installed() {
    # Only run on macOS
    if [[ "$OS_TYPE" != "macos" ]]; then
        return 0
    fi
    
    local arch=$(uname -m)
    local expected_brew_path
    local homebrew_prefix
    
    # Determine expected paths based on architecture
    if [[ "$arch" == "arm64" ]]; then
        expected_brew_path="/opt/homebrew/bin/brew"
        homebrew_prefix="/opt/homebrew"
        log_action "Homebrew" "Detected Apple Silicon (ARM64)" "installing"
    else
        expected_brew_path="/usr/local/bin/brew"
        homebrew_prefix="/usr/local"
        log_action "Homebrew" "Detected Intel (x86_64)" "installing"
    fi
    
    # Check if Homebrew is already installed and accessible
    if command -v brew &>/dev/null; then
        local current_brew_path=$(which brew)
        log_action "Homebrew" "Found at $current_brew_path" "already"
        
        # Verify it's in the expected location for the architecture
        if [[ "$current_brew_path" == "$expected_brew_path" ]]; then
            log_action "Homebrew" "Correct path for architecture" "success"
        else
            log_action "Homebrew" "Unexpected path: $current_brew_path (expected: $expected_brew_path)" "installing"
        fi
        return 0
    fi
    
    # Check if Homebrew exists but isn't in PATH
    if [[ -f "$expected_brew_path" ]]; then
        log_action "Homebrew" "Found but not in PATH, configuring..." "installing"
        eval "$($expected_brew_path shellenv)"
        export PATH="$homebrew_prefix/bin:$PATH"
        
        if command -v brew &>/dev/null; then
            log_action "Homebrew" "Successfully added to PATH" "success"
            return 0
        fi
    fi
    
    # Install Homebrew if not found
    log_action "Homebrew" "Installing Homebrew for $arch architecture" "installing"
    
    # Verify we can download the install script securely
    local install_script_url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    local install_script="/tmp/homebrew_install.sh"
    
    if ! curl -fsSL "$install_script_url" -o "$install_script"; then
        echo -e "${RED}Failed to download Homebrew install script${NC}"
        return 1
    fi
    
    # Basic validation of the install script
    if ! grep -q "Homebrew" "$install_script"; then
        echo -e "${RED}Downloaded script doesn't appear to be the Homebrew installer${NC}"
        rm -f "$install_script"
        return 1
    fi
    
    # Run the installer
    if /bin/bash "$install_script"; then
        rm -f "$install_script"
        log_action "Homebrew" "Installation completed" "success"
        
        # Configure environment for current session
        if [[ -f "$expected_brew_path" ]]; then
            eval "$($expected_brew_path shellenv)"
            export PATH="$homebrew_prefix/bin:$PATH"
            
            # Verify installation
            if command -v brew &>/dev/null; then
                log_action "Homebrew" "Successfully configured and accessible" "success"
                
                # Add to shell profile for persistence
                local shell_profile
                case "$SHELL" in
                    */zsh)
                        shell_profile="$HOME/.zshrc"
                        ;;
                    */bash)
                        shell_profile="$HOME/.bash_profile"
                        ;;
                    *)
                        shell_profile="$HOME/.profile"
                        ;;
                esac
                
                if [[ -f "$shell_profile" ]] && ! grep -q "$homebrew_prefix/bin" "$shell_profile"; then
                    echo "# Added by Neovim installation script" >> "$shell_profile"
                    echo "eval \"\$($expected_brew_path shellenv)\"" >> "$shell_profile"
                    log_action "Homebrew" "Added to $shell_profile for future sessions" "success"
                fi
                
                return 0
            else
                echo -e "${RED}Homebrew installed but not accessible${NC}"
                return 1
            fi
        else
            echo -e "${RED}Homebrew installation completed but binary not found at expected path${NC}"
            return 1
        fi
    else
        rm -f "$install_script"
        echo -e "${RED}Homebrew installation failed${NC}"
        return 1
    fi
}

# Cross-platform package installation function
install_package() {
    local package_name="$1"
    local linux_package="$2"
    local macos_package="$3"
    
    ensure_package_manager_updated
    
    case "$OS_TYPE" in
        "linux")
            sudo apt install -y "${linux_package:-$package_name}"
            ;;
        "macos")
            brew install "${macos_package:-$package_name}"
            ;;
    esac
}

# Cross-platform checksum verification function
verify_checksum() {
    local file="$1"
    local expected_checksum="$2"
    local algorithm="${3:-sha256}"
    
    if [[ -z "$expected_checksum" ]]; then
        log_action "Checksum" "No checksum provided, skipping verification" "skip"
        return 0
    fi
    
    local actual_checksum
    case "$algorithm" in
        sha256)
            if command -v shasum &>/dev/null; then
                actual_checksum=$(shasum -a 256 "$file" | cut -d' ' -f1)
            elif command -v sha256sum &>/dev/null; then
                actual_checksum=$(sha256sum "$file" | cut -d' ' -f1)
            else
                log_action "Checksum" "No SHA256 tool available (shasum/sha256sum)" "failed"
                return 1
            fi
            ;;
        *)
            log_action "Checksum" "Unsupported algorithm: $algorithm" "failed"
            return 1
            ;;
    esac
    
    if [[ "$actual_checksum" == "$expected_checksum" ]]; then
        log_action "Checksum" "Verification successful" "success"
        return 0
    else
        log_action "Checksum" "Verification failed" "failed"
        echo -e "${RED}Expected: $expected_checksum${NC}"
        echo -e "${RED}Actual:   $actual_checksum${NC}"
        return 1
    fi
}

# Enhanced download function with checksum verification
download_and_verify() {
    local url="$1"
    local output_file="$2"
    local expected_checksum="$3"
    local description="$4"
    
    log_action "Download" "Downloading $description" "installing"
    
    # Download with timeout and error checking
    if ! retry_network_operation "Download $description" "curl -L --connect-timeout 30 --max-time 120 -o '$output_file' '$url'"; then
        echo -e "${RED}Failed to download $description${NC}"
        return 1
    fi
    
    # Verify file exists and has content
    if [[ ! -f "$output_file" ]] || [[ ! -s "$output_file" ]]; then
        echo -e "${RED}Downloaded file is empty or doesn't exist${NC}"
        return 1
    fi
    
    # Verify checksum if provided
    if [[ -n "$expected_checksum" ]]; then
        if ! verify_checksum "$output_file" "$expected_checksum" "sha256"; then
            echo -e "${RED}Checksum verification failed for $description${NC}"
            rm -f "$output_file"
            return 1
        fi
    fi
    
    log_action "Download" "$description downloaded and verified" "success"
    return 0
}

# Helper function for retrying network operations
retry_network_operation() {
    local description="$1"
    local command="$2"
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -le $max_retries ]; do
        if eval "$command"; then
            return 0
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -le $max_retries ]; then
                echo -e "${YELLOW}$description failed, retrying ($retry_count/$max_retries)...${NC}"
                sleep 3
            fi
        fi
    done
    
    echo -e "${RED}$description failed after $max_retries attempts${NC}"
    return 1
}

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
            case "$OS_TYPE" in
                "linux")
                    echo "  # Using AppImage:"
                    echo "  curl -LO https://github.com/neovim/neovim/releases/download/v0.10.3/nvim.appimage"
                    echo "  chmod u+x nvim.appimage"
                    echo "  sudo mv nvim.appimage /usr/local/bin/nvim"
                    echo ""
                    echo "  # Or using package manager:"
                    echo "  sudo apt install -y neovim"
                    ;;
                "macos")
                    echo "  # Using Homebrew:"
                    echo "  brew install neovim"
                    echo ""
                    echo "  # Or using MacPorts:"
                    echo "  sudo port install neovim"
                    ;;
            esac
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
            case "$OS_TYPE" in
                "linux")
                    log_action "Git" "Installing via apt" "installing"
                    if install_and_update_state "git_install" "install_package git" "command -v git"; then
                        log_action "Git" "Installation completed" "success"
                    else
                        log_action "Git" "Installation failed" "failed"
                        exit 1
                    fi
                    ;;
                "macos")
                    log_action "Git" "Installing via Homebrew" "installing"
                    if install_and_update_state "git_install" "install_package git" "command -v git"; then
                        log_action "Git" "Installation completed" "success"
                    else
                        log_action "Git" "Installation failed" "failed"
                        exit 1
                    fi
                    ;;
            esac
        fi
    else
        log_action "Git" "Installation" "skip"
    fi
}

# Install yq and jq for YAML/JSON processing
install_yq_jq() {
    # Install yq
    if needs_action "yq_install"; then
        if check_and_update_state "yq_install" "command -v yq"; then
            log_action "yq" "Already available" "already"
        else
            case "$OS_TYPE" in
                "linux")
                    log_action "yq" "Installing via apt" "installing"
                    if install_and_update_state "yq_install" "install_package yq" "command -v yq"; then
                        log_action "yq" "Installation completed" "success"
                    else
                        log_action "yq" "Installation failed" "failed"
                        echo -e "${RED}yq is required for state management. Please install manually:${NC}"
                        echo "  wget -qO- https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 | sudo tee /usr/local/bin/yq > /dev/null"
                        echo "  sudo chmod +x /usr/local/bin/yq"
                        exit 1
                    fi
                    ;;
                "macos")
                    log_action "yq" "Installing via Homebrew" "installing"
                    if install_and_update_state "yq_install" "install_package yq" "command -v yq"; then
                        log_action "yq" "Installation completed" "success"
                    else
                        log_action "yq" "Installation failed" "failed"
                        echo -e "${RED}yq is required for state management. Please install manually:${NC}"
                        echo "  brew install yq"
                        exit 1
                    fi
                    ;;
            esac
        fi
    else
        log_action "yq" "Installation" "skip"
    fi
    
    # Install jq
    if needs_action "jq_install"; then
        if check_and_update_state "jq_install" "command -v jq"; then
            log_action "jq" "Already available" "already"
        else
            case "$OS_TYPE" in
                "linux")
                    log_action "jq" "Installing via apt" "installing"
                    if install_and_update_state "jq_install" "install_package jq" "command -v jq"; then
                        log_action "jq" "Installation completed" "success"
                    else
                        log_action "jq" "Installation failed" "failed"
                    fi
                    ;;
                "macos")
                    log_action "jq" "Installing via Homebrew" "installing"
                    if install_and_update_state "jq_install" "install_package jq" "command -v jq"; then
                        log_action "jq" "Installation completed" "success"
                    else
                        log_action "jq" "Installation failed" "failed"
                    fi
                    ;;
            esac
        fi
    else
        log_action "jq" "Installation" "skip"
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
            case "$OS_TYPE" in
                "linux")
                    log_action "Ripgrep" "Installing via apt" "installing"
                    if install_and_update_state "ripgrep_install" "install_package ripgrep" "command -v rg"; then
                        log_action "Ripgrep" "Installation completed" "success"
                    else
                        log_action "Ripgrep" "Installation failed" "failed"
                    fi
                    ;;
                "macos")
                    log_action "Ripgrep" "Installing via Homebrew" "installing"
                    if install_and_update_state "ripgrep_install" "install_package ripgrep" "command -v rg"; then
                        log_action "Ripgrep" "Installation completed" "success"
                    else
                        log_action "Ripgrep" "Installation failed" "failed"
                    fi
                    ;;
            esac
        fi
    else
        log_action "Ripgrep" "Installation" "skip"
    fi
    
# Helper function to install fd with cross-platform support
install_fd_binary() {
    case "$OS_TYPE" in
        "linux")
            # Ensure package manager is updated first
            ensure_package_manager_updated
            
            # Install fd-find package on Linux
            if ! install_package fd fd-find; then
                echo -e "${RED}Failed to install fd-find package${NC}"
                return 1
            fi
            
            # Check if fdfind binary exists
            local fdfind_path
            fdfind_path=$(which fdfind 2>/dev/null)
            if [[ -z "$fdfind_path" ]]; then
                echo -e "${RED}fdfind binary not found after installation${NC}"
                return 1
            fi
            
            # Create symlink for fd command
            log_action "fd" "Creating symlink for fd command" "installing"
            if ! sudo ln -sf "$fdfind_path" /usr/local/bin/fd; then
                echo -e "${YELLOW}Warning: Failed to create fd symlink, but fdfind is available${NC}"
                # Don't fail completely as fdfind still works
            fi
            ;;
        "macos")
            # On macOS, fd is available directly via Homebrew
            if ! install_package fd; then
                echo -e "${RED}Failed to install fd package${NC}"
                return 1
            fi
            ;;
    esac
    
    # Verify fd command works (either as fd or fdfind)
    if command -v fd &>/dev/null || command -v fdfind &>/dev/null; then
        return 0
    else
        echo -e "${RED}Neither fd nor fdfind command is available${NC}"
        return 1
    fi
}
    
    # fd
    if needs_action "fd_install"; then
        if check_and_update_state "fd_install" "command -v fd || command -v fdfind"; then
            log_action "fd" "Already available" "already"
        else
            case "$OS_TYPE" in
                "linux")
                    log_action "fd" "Installing via apt" "installing"
                    ;;
                "macos")
                    log_action "fd" "Installing via Homebrew" "installing"
                    ;;
            esac
            if install_fd_binary; then
                set_state "fd_install" "installed"
                log_action "fd" "Installation completed" "success"
            else
                set_state "fd_install" "notinstalled"
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
            case "$OS_TYPE" in
                "linux")
                    log_action "fzf" "Installing from source" "installing"
                    install_cmd="git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all --no-bash --no-zsh --no-fish"
                    if install_and_update_state "fzf_install" "$install_cmd" "command -v fzf || test -f ~/.fzf/bin/fzf"; then
                        log_action "fzf" "Installation completed" "success"
                        export PATH="$HOME/.fzf/bin:$PATH"
                    else
                        log_action "fzf" "Installation failed" "failed"
                    fi
                    ;;
                "macos")
                    log_action "fzf" "Installing via Homebrew" "installing"
                    if install_and_update_state "fzf_install" "install_package fzf" "command -v fzf"; then
                        log_action "fzf" "Installation completed" "success"
                    else
                        log_action "fzf" "Installation failed" "failed"
                    fi
                    ;;
            esac
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
            case "$OS_TYPE" in
                "linux")
                    log_action "Node.js" "Installing LTS version via NodeSource" "installing"
                    install_cmd="curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && install_package nodejs"
                    if install_and_update_state "node_install" "$install_cmd" "command -v node"; then
                        log_action "Node.js" "Installation completed" "success"
                    else
                        log_action "Node.js" "Installation failed" "failed"
                    fi
                    ;;
                "macos")
                    log_action "Node.js" "Installing LTS version via Homebrew" "installing"
                    if install_and_update_state "node_install" "install_package node" "command -v node"; then
                        log_action "Node.js" "Installation completed" "success"
                    else
                        log_action "Node.js" "Installation failed" "failed"
                    fi
                    ;;
            esac
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
            case "$OS_TYPE" in
                "linux")
                    log_action "Python3" "Installing via apt" "installing"
                    if install_and_update_state "python_install" "install_package python3 python3; install_package python3-pip python3-pip" "command -v python3"; then
                        log_action "Python3" "Installation completed" "success"
                    else
                        log_action "Python3" "Installation failed" "failed"
                    fi
                    ;;
                "macos")
                    log_action "Python3" "Installing via Homebrew" "installing"
                    if install_and_update_state "python_install" "install_package python3 python" "command -v python3"; then
                        log_action "Python3" "Installation completed" "success"
                    else
                        log_action "Python3" "Installation failed" "failed"
                    fi
                    ;;
            esac
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
        case "$OS_TYPE" in
            "linux")
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
                ;;
            "macos")
                if check_and_update_state "fonts_install" "system_profiler SPFontsDataType | grep -q 'JetBrains Mono'"; then
                    log_action "JetBrains Mono" "Already installed" "already"
                else
                    log_action "JetBrains Mono" "Installing via Homebrew" "installing"
                    if install_and_update_state "fonts_install" "install_package font-jetbrains-mono homebrew/cask-fonts/font-jetbrains-mono" "system_profiler SPFontsDataType | grep -q 'JetBrains Mono'"; then
                        log_action "JetBrains Mono" "Installation completed" "success"
                    else
                        log_action "JetBrains Mono" "Installation failed, trying manual installation" "installing"
                        install_cmd="curl -L https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip -o /tmp/JetBrainsMono.zip && unzip -q /tmp/JetBrainsMono.zip -d /tmp/JetBrainsMono && cp -R /tmp/JetBrainsMono/fonts/ttf/*.ttf ~/Library/Fonts/ && rm -rf /tmp/JetBrainsMono*"
                        if install_and_update_state "fonts_install" "$install_cmd" "ls ~/Library/Fonts/ | grep -q JetBrainsMono"; then
                            log_action "JetBrains Mono" "Manual installation completed" "success"
                        else
                            log_action "JetBrains Mono" "Installation failed" "failed"
                        fi
                    fi
                fi
                ;;
        esac
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
                log_action "Config Backup" "Backup created: $(basename "$backup_name")" "success"
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

# Install new configuration (always copy to prevent drift)
install_config() {
    if needs_action "config_install"; then
        log_action "Config Install" "Copying configuration files to prevent drift" "installing"
        if mkdir -p "$HOME/.config/nvim" && cp -r ./* "$HOME/.config/nvim/"; then
            set_state "config_install" "installed"
            log_action "Config Install" "Configuration files copied" "success"
        else
            set_state "config_install" "notinstalled"
            log_action "Config Install" "Copy failed" "failed"
        fi
    else
        # Always copy configs even if marked as installed to prevent drift
        log_action "Config Install" "Updating configs to prevent drift" "installing"
        if cp -r ./* "$HOME/.config/nvim/" 2>/dev/null; then
            log_action "Config Install" "Configuration updated successfully" "success"
        else
            log_action "Config Install" "Configuration update failed" "failed"
        fi
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

# Helper function to install LazyGit from GitHub releases
install_lazygit_binary() {
    local temp_dir
    temp_dir=$(mktemp -d)
    cleanup() { rm -rf "$temp_dir"; }
    trap cleanup EXIT
    
    # Get latest version from GitHub API
    log_action "LazyGit" "Fetching latest version info" "installing"
    local version
    version=$(curl -s --connect-timeout 10 "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    
    if [[ -z "$version" ]]; then
        echo -e "${RED}Failed to get LazyGit version information${NC}"
        return 1
    fi
    
    log_action "LazyGit" "Downloading version $version" "installing"
    local download_url
    case "$OS_TYPE" in
        "linux")
            download_url="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Linux_x86_64.tar.gz"
            ;;
        "macos")
            # Detect macOS architecture (Apple Silicon vs Intel)
            local mac_arch
            mac_arch=$(uname -m)
            if [[ "$mac_arch" == "arm64" ]]; then
                download_url="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Darwin_arm64.tar.gz"
                log_action "LazyGit" "Detected Apple Silicon (ARM64)" "installing"
            else
                download_url="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Darwin_x86_64.tar.gz"
                log_action "LazyGit" "Detected Intel (x86_64)" "installing"
            fi
            ;;
    esac
    
    # Download with timeout and error checking
    if ! curl -L --connect-timeout 30 --max-time 120 -o "$temp_dir/lazygit.tar.gz" "$download_url"; then
        echo -e "${RED}Failed to download LazyGit${NC}"
        return 1
    fi
    
    # Basic file verification - ensure it's a valid gzip file
    log_action "LazyGit" "Verifying download integrity" "installing"
    if ! file "$temp_dir/lazygit.tar.gz" | grep -q "gzip compressed"; then
        echo -e "${RED}Downloaded file is not a valid gzip archive${NC}"
        return 1
    fi
    
    # Check file size is reasonable (should be > 1MB and < 50MB)
    local file_size
    file_size=$(stat -f%z "$temp_dir/lazygit.tar.gz" 2>/dev/null || stat -c%s "$temp_dir/lazygit.tar.gz" 2>/dev/null)
    if [[ -n "$file_size" ]]; then
        if [[ "$file_size" -lt 1000000 ]] || [[ "$file_size" -gt 50000000 ]]; then
            echo -e "${YELLOW}Warning: LazyGit download size ($file_size bytes) seems unusual${NC}"
            echo -e "${YELLOW}Continuing anyway, but please verify the installation${NC}"
        fi
    fi
    
    # Extract and verify
    log_action "LazyGit" "Extracting and installing binary" "installing"
    cd "$temp_dir" || return 1
    
    if ! tar xf lazygit.tar.gz; then
        echo -e "${RED}Failed to extract LazyGit archive${NC}"
        return 1
    fi
    
    if [[ ! -f "lazygit" ]] || [[ ! -x "lazygit" ]]; then
        echo -e "${RED}LazyGit binary not found or not executable${NC}"
        return 1
    fi
    
    # Install to system
    case "$OS_TYPE" in
        "linux")
            if ! sudo install lazygit /usr/local/bin/; then
                echo -e "${RED}Failed to install LazyGit to /usr/local/bin${NC}"
                return 1
            fi
            ;;
        "macos")
            # Try /usr/local/bin first, fall back to user directory if needed
            if sudo install lazygit /usr/local/bin/ 2>/dev/null; then
                log_action "LazyGit" "Installed to /usr/local/bin" "success"
            elif install lazygit "$HOME/.local/bin/" 2>/dev/null; then
                mkdir -p "$HOME/.local/bin"
                cp lazygit "$HOME/.local/bin/"
                chmod +x "$HOME/.local/bin/lazygit"
                # Add to PATH if not already there
                if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                    export PATH="$HOME/.local/bin:$PATH"
                fi
                log_action "LazyGit" "Installed to $HOME/.local/bin" "success"
            else
                echo -e "${RED}Failed to install LazyGit${NC}"
                return 1
            fi
            ;;
    esac
    
    # Verify installation
    if ! command -v lazygit &>/dev/null; then
        echo -e "${RED}LazyGit installation verification failed${NC}"
        return 1
    fi
    
    return 0
}

# Install lazygit for Git workflow
install_lazygit() {
    if needs_action "lazygit_install"; then
        if check_and_update_state "lazygit_install" "command -v lazygit"; then
            log_action "LazyGit" "Already available" "already"
        else
            case "$OS_TYPE" in
                "linux")
                    log_action "LazyGit" "Installing via GitHub releases" "installing"
                    if install_lazygit_binary; then
                        set_state "lazygit_install" "installed"
                        log_action "LazyGit" "Installation completed" "success"
                    else
                        set_state "lazygit_install" "notinstalled"
                        log_action "LazyGit" "Installation failed" "failed"
                        echo -e "${YELLOW}Note: LazyGit installation failed. You can install manually:${NC}"
                        echo "  https://github.com/jesseduffield/lazygit#installation"
                    fi
                    ;;
                "macos")
                    log_action "LazyGit" "Installing via Homebrew" "installing"
                    if install_and_update_state "lazygit_install" "install_package lazygit" "command -v lazygit"; then
                        log_action "LazyGit" "Installation completed" "success"
                    else
                        log_action "LazyGit" "Homebrew installation failed, trying GitHub releases" "installing"
                        if install_lazygit_binary; then
                            set_state "lazygit_install" "installed"
                            log_action "LazyGit" "GitHub installation completed" "success"
                        else
                            set_state "lazygit_install" "notinstalled"
                            log_action "LazyGit" "Installation failed" "failed"
                            echo -e "${YELLOW}Note: LazyGit installation failed. You can install manually:${NC}"
                            echo "  brew install lazygit"
                            echo "  Or: https://github.com/jesseduffield/lazygit#installation"
                        fi
                    fi
                    ;;
            esac
        fi
    else
        log_action "LazyGit" "Already installed" "skip"
    fi
}

# Install tmux configuration
install_tmux() {
    if [ "$SKIP_TMUX" = true ]; then
        log_action "Tmux" "Skipped by user flag" "skip"
        return
    fi
    
    if needs_action "tmux_install"; then
        # Check if tmux is installed
        if ! command -v tmux &> /dev/null; then
            case "$OS_TYPE" in
                "linux")
                    log_action "Tmux" "Installing tmux binary via apt" "installing"
                    install_package tmux
                    ;;
                "macos")
                    log_action "Tmux" "Installing tmux binary via Homebrew" "installing"
                    install_package tmux
                    ;;
            esac
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
    
    # Check if there are unchecked components and inform user
    if has_unchecked_components; then
        echo -e "${BLUE}ℹ️  Found components that need checking. Running full scan...${NC}"
    fi
    
    # Run all installation functions - they will check their own state
    check_neovim
    install_git
    install_yq_jq
    install_dependencies
    install_node
    install_python
    install_fonts
    backup_config
    install_config
    install_lazyvim
    install_plugins
    install_lazygit
    install_tmux
    
    # Final state check and summary
    echo -e "\n${GREEN}✅ Installation process complete!${NC}"
    echo -e "\n${BLUE}Installation Summary:${NC}"
    show_state
    
    # Check if all components are now properly checked
    if has_unchecked_components; then
        echo -e "\n${YELLOW}⚠️  Some components are still unchecked. This might indicate an issue.${NC}"
        echo -e "${YELLOW}Run './install.sh --reset-state' if you want to force a complete re-check.${NC}"
    else
        echo -e "\n${GREEN}✅ All components have been checked and configured.${NC}"
    fi
    
    echo -e "\n${GREEN}Next steps:${NC}"
    echo -e "1. Open Neovim: ${YELLOW}nvim${NC}"
    if [ "$SKIP_PLUGINS" = false ]; then
        echo -e "2. Wait for plugins to install automatically"
    else
        echo -e "2. Run ${YELLOW}:Lazy sync${NC} to install plugins"
    fi
    echo -e "3. Run ${YELLOW}:checkhealth${NC} to verify setup"
    echo -e "4. Read the usage guide: ${YELLOW}nvim ~/claude/nvim/USAGE_GUIDE.md${NC}"
    if [ "$SKIP_TMUX" = false ]; then
        echo -e "5. Start tmux: ${YELLOW}tmux${NC} (optimized configuration installed)"
    fi
    echo -e "\n${GREEN}Happy coding! 🎉${NC}"
    echo -e "\n${BLUE}💡 Tip: Run './install.sh --show-state' to check installation status anytime${NC}"
}

# Run main installation
main