#!/bin/bash

# State Management for Neovim Configuration Installation
# This module handles reading/writing installation state to ~/.config/claude-nvim/state.yaml

STATE_DIR="$HOME/.config/claude-nvim"
STATE_FILE="$STATE_DIR/state.yaml"

# Ensure state directory exists
init_state() {
    mkdir -p "$STATE_DIR"
    
    # Create initial state file if it doesn't exist
    if [ ! -f "$STATE_FILE" ]; then
        cat > "$STATE_FILE" << 'EOF'
# Neovim Configuration Installation State
# Values: notcheckedyet, installed, notinstalled
neovim_check: notcheckedyet
git_install: notcheckedyet
ripgrep_install: notcheckedyet
fd_install: notcheckedyet
fzf_install: notcheckedyet
node_install: notcheckedyet
python_install: notcheckedyet
fonts_install: notcheckedyet
config_backup: notcheckedyet
config_install: notcheckedyet
lazyvim_install: notcheckedyet
plugins_install: notcheckedyet
tmux_install: notcheckedyet
EOF
    fi
}

# Get state of a component
get_state() {
    local component="$1"
    yq eval ".${component}" "$STATE_FILE" 2>/dev/null || echo "notcheckedyet"
}

# Set state of a component
set_state() {
    local component="$1"
    local state="$2"
    
    # Validate state value
    case "$state" in
        notcheckedyet|installed|notinstalled)
            yq eval ".${component} = \"${state}\"" -i "$STATE_FILE"
            ;;
        *)
            echo "Invalid state: $state. Must be: notcheckedyet, installed, notinstalled"
            return 1
            ;;
    esac
}

# Check if component needs installation/checking
needs_action() {
    local component="$1"
    local current_state=$(get_state "$component")
    
    case "$current_state" in
        notcheckedyet|notinstalled)
            return 0  # Needs action
            ;;
        installed)
            return 1  # No action needed
            ;;
        *)
            return 0  # Unknown state, check it
            ;;
    esac
}

# Mark component as checked and determine if it's installed
check_and_update_state() {
    local component="$1"
    local check_command="$2"
    
    if eval "$check_command" &>/dev/null; then
        set_state "$component" "installed"
        return 0  # Already installed
    else
        set_state "$component" "notinstalled"
        return 1  # Not installed
    fi
}

# Install component and update state
install_and_update_state() {
    local component="$1"
    local install_command="$2"
    local check_command="$3"
    
    # Try to install
    if eval "$install_command"; then
        # Verify installation worked
        if eval "$check_command" &>/dev/null; then
            set_state "$component" "installed"
            return 0  # Successfully installed
        else
            # Installation command succeeded but check failed
            set_state "$component" "notinstalled"
            return 1  # Installation failed
        fi
    else
        set_state "$component" "notinstalled"
        return 1  # Installation command failed
    fi
}

# Show current state summary
show_state() {
    echo "Current installation state:"
    echo "=========================="
    yq eval 'to_entries | .[] | .key + ": " + .value' "$STATE_FILE"
}

# Reset all states to notcheckedyet (for testing)
reset_state() {
    local components=(
        "neovim_check" "git_install" "ripgrep_install" "fd_install" 
        "fzf_install" "node_install" "python_install" "fonts_install"
        "config_backup" "config_install" "lazyvim_install" "plugins_install" "tmux_install"
    )
    
    for component in "${components[@]}"; do
        set_state "$component" "notcheckedyet"
    done
    echo "All states reset to 'notcheckedyet'"
}