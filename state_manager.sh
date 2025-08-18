#!/bin/bash

# State Management for Neovim Configuration Installation
# This module handles reading/writing installation state to ~/.config/claude-nvim/state.yaml

STATE_DIR="$HOME/.config/claude-nvim"
STATE_FILE="$STATE_DIR/state.yaml"

# Valid component names (whitelist for security)
VALID_COMPONENTS=(
    "neovim_check" "git_install" "ripgrep_install" "fd_install"
    "fzf_install" "node_install" "python_install" "lua_install" "luarocks_install" "fonts_install"
    "config_backup" "config_install" "lazyvim_install" "plugins_install" "tmux_install"
    "lazygit_install" "yq_install" "jq_install"
)

# Validate component name for security
validate_component_name() {
    local component="$1"
    local valid_component

    # Check if component name matches our whitelist
    for valid_component in "${VALID_COMPONENTS[@]}"; do
        if [[ "$component" == "$valid_component" ]]; then
            return 0
        fi
    done

    echo "Error: Invalid component name '$component'" >&2
    return 1
}

# Ensure state directory exists
init_state() {
    # Check if yq is available (will be installed if missing)
    if ! command -v yq &>/dev/null; then
        echo "Warning: yq not found - will be installed as part of setup"
    fi

    # Check if jq is available (will be installed if missing)
    if ! command -v jq &>/dev/null; then
        echo "Warning: jq not found - will be installed as part of setup"
    fi

    mkdir -p "$STATE_DIR"

    # Create initial state file if it doesn't exist
    if [ ! -f "$STATE_FILE" ]; then
        cat > "$STATE_FILE" << 'EOF'
# Neovim Configuration Installation State
# Values: notcheckedyet, installed, notinstalled
neovim_check: notcheckedyet
git_install: notcheckedyet
yq_install: notcheckedyet
jq_install: notcheckedyet
ripgrep_install: notcheckedyet
fd_install: notcheckedyet
fzf_install: notcheckedyet
node_install: notcheckedyet
python_install: notcheckedyet
lua_install: notcheckedyet
luarocks_install: notcheckedyet
fonts_install: notcheckedyet
config_backup: notcheckedyet
config_install: notcheckedyet
lazyvim_install: notcheckedyet
plugins_install: notcheckedyet
lazygit_install: notcheckedyet
tmux_install: notcheckedyet
EOF
    fi
}

# Get state of a component
get_state() {
    local component="$1"

    # Validate component name for security
    validate_component_name "$component" || return 1

    yq eval ".${component}" "$STATE_FILE" 2>/dev/null || echo "notcheckedyet"
}

# Set state of a component
set_state() {
    local component="$1"
    local state="$2"

    # Validate component name for security
    validate_component_name "$component" || return 1

    # Validate state value
    case "$state" in
        notcheckedyet|installed|notinstalled)
            yq eval ".${component} = \"${state}\"" -i "$STATE_FILE"
            ;;
        *)
            echo "Invalid state: $state. Must be: notcheckedyet, installed, notinstalled" >&2
            return 1
            ;;
    esac
}

# Check if component needs installation/checking
needs_action() {
    local component="$1"

    # Validate component name for security
    validate_component_name "$component" || return 1

    local current_state
    current_state=$(get_state "$component")

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

    # Validate component name for security
    validate_component_name "$component" || return 1

    # Security note: check_command should only be called with trusted input from install.sh
    # This eval is necessary for command flexibility but requires controlled input
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

    # Validate component name for security
    validate_component_name "$component" || return 1

    # Security note: install_command and check_command should only be called with
    # trusted input from install.sh. These eval calls are necessary for command
    # flexibility but require controlled input to prevent injection attacks.

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

# Get all components with notcheckedyet status
get_unchecked_components() {
    yq eval 'to_entries | map(select(.value == "notcheckedyet")) | .[].key' "$STATE_FILE" 2>/dev/null
}

# Check if there are any unchecked components
has_unchecked_components() {
    local unchecked_count
    unchecked_count=$(yq eval 'to_entries | map(select(.value == "notcheckedyet")) | length' "$STATE_FILE" 2>/dev/null)
    [ "$unchecked_count" -gt 0 ]
}

# Reset all states to notcheckedyet (for testing)
reset_state() {
    local components=(
        "neovim_check" "git_install" "yq_install" "jq_install" "ripgrep_install" "fd_install"
        "fzf_install" "node_install" "python_install" "lua_install" "luarocks_install" "fonts_install"
        "config_backup" "config_install" "lazyvim_install" "plugins_install" "lazygit_install" "tmux_install"
    )

    for component in "${components[@]}"; do
        set_state "$component" "notcheckedyet"
    done
    echo "All states reset to 'notcheckedyet'"
}
