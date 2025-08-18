#!/bin/bash

# Integration Testing for Neovim Installation Script
# Tests actual script execution and cross-platform functionality

set -e

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_SCRIPT="$SCRIPT_DIR/../install.sh"

# Test framework functions
assert_success() {
    local command="$1"
    local test_name="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    if eval "$command" &>/dev/null; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo -e "  Command failed: ${YELLOW}$command${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_contains() {
    local output="$1"
    local expected="$2"
    local test_name="$3"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    if [[ "$output" == *"$expected"* ]]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo -e "  Expected to contain: ${YELLOW}$expected${NC}"
        echo -e "  Actual output: ${YELLOW}${output:0:100}...${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test script execution
test_script_execution() {
    echo -e "\n${BLUE}Testing Script Execution${NC}"
    
    # Test help flag
    local help_output
    help_output=$("$INSTALL_SCRIPT" --help 2>&1)
    assert_contains "$help_output" "Neovim Configuration Installation Script" "Help output contains title"
    assert_contains "$help_output" "--skip-tmux" "Help output contains skip-tmux option"
    assert_contains "$help_output" "Options:" "Help output contains options section"
    
    # Test show-state flag
    assert_success "$INSTALL_SCRIPT --show-state" "Show state command execution"
    
    # Test syntax validation
    assert_success "bash -n $INSTALL_SCRIPT" "Script syntax validation"
}

# Test OS detection
test_os_detection_integration() {
    echo -e "\n${BLUE}Testing OS Detection Integration${NC}"
    
    # Test that script detects current OS
    local os_output
    os_output=$("$INSTALL_SCRIPT" --help 2>&1 | head -1)
    assert_contains "$os_output" "Detected OS:" "OS detection in script output"
    
    # Verify current OS is detected correctly
    local current_os
    current_os=$(uname -s)
    case "$current_os" in
        Linux*)
            assert_contains "$os_output" "linux" "Linux OS detection"
            ;;
        Darwin*)
            assert_contains "$os_output" "macos" "macOS OS detection"
            ;;
    esac
}

# Test command line argument parsing
test_argument_parsing() {
    echo -e "\n${BLUE}Testing Argument Parsing${NC}"
    
    # Test invalid argument
    local invalid_output
    invalid_output=$("$INSTALL_SCRIPT" --invalid-flag 2>&1 || true)
    assert_contains "$invalid_output" "Unknown option" "Invalid argument handling"
    
    # Test valid arguments don't cause syntax errors
    assert_success "$INSTALL_SCRIPT --skip-fonts --show-state" "Multiple valid arguments"
    assert_success "$INSTALL_SCRIPT --skip-tmux --show-state" "Skip tmux argument"
    assert_success "$INSTALL_SCRIPT --reset-state" "Reset state argument"
}

# Test state management
test_state_management() {
    echo -e "\n${BLUE}Testing State Management${NC}"
    
    # Test state display
    local state_output
    state_output=$("$INSTALL_SCRIPT" --show-state 2>&1)
    assert_contains "$state_output" "Current installation state" "State display header"
    assert_contains "$state_output" "tmux_install:" "Tmux component in state"
    assert_contains "$state_output" "yq_install:" "yq component in state"
    assert_contains "$state_output" "lazygit_install:" "LazyGit component in state"
}

# Test dependency checks
test_dependency_checks() {
    echo -e "\n${BLUE}Testing Dependency Checks${NC}"
    
    # Check for required commands on the system
    local required_commands=("curl" "git" "tar")
    
    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" &>/dev/null; then
            echo -e "${GREEN}✓ FOUND${NC}: Required command '$cmd' is available"
        else
            echo -e "${YELLOW}⚠ MISSING${NC}: Required command '$cmd' not found"
        fi
    done
}

# Test checksum functionality
test_checksum_functionality() {
    echo -e "\n${BLUE}Testing Checksum Functionality${NC}"
    
    # Test shasum availability
    if command -v shasum &>/dev/null; then
        assert_success "echo 'test' | shasum -a 256" "SHA256 checksum calculation"
        echo -e "${GREEN}✓ FOUND${NC}: shasum command available for checksum verification"
    elif command -v sha256sum &>/dev/null; then
        assert_success "echo 'test' | sha256sum" "SHA256 checksum calculation (sha256sum)"
        echo -e "${GREEN}✓ FOUND${NC}: sha256sum command available for checksum verification"
    else
        echo -e "${YELLOW}⚠ MISSING${NC}: No SHA256 command found (shasum or sha256sum)"
    fi
}

# Test Homebrew detection (macOS only)
test_homebrew_detection() {
    echo -e "\n${BLUE}Testing Homebrew Detection${NC}"
    
    if [[ "$(uname -s)" == "Darwin" ]]; then
        # Test Homebrew paths
        local brew_paths=("/opt/homebrew/bin/brew" "/usr/local/bin/brew")
        local brew_found=false
        
        for brew_path in "${brew_paths[@]}"; do
            if [[ -f "$brew_path" ]]; then
                echo -e "${GREEN}✓ FOUND${NC}: Homebrew at $brew_path"
                brew_found=true
                break
            fi
        done
        
        if [[ "$brew_found" == false ]]; then
            echo -e "${YELLOW}⚠ MISSING${NC}: Homebrew not found in standard locations"
        fi
        
        # Test architecture-specific paths
        local arch
        arch=$(uname -m)
        if [[ "$arch" == "arm64" ]]; then
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                echo -e "${GREEN}✓ CORRECT${NC}: ARM64 Homebrew path detected"
            else
                echo -e "${YELLOW}⚠ MISMATCH${NC}: ARM64 Mac but no /opt/homebrew/bin/brew"
            fi
        else
            if [[ -f "/usr/local/bin/brew" ]]; then
                echo -e "${GREEN}✓ CORRECT${NC}: Intel Homebrew path detected"
            else
                echo -e "${YELLOW}⚠ MISMATCH${NC}: Intel Mac but no /usr/local/bin/brew"
            fi
        fi
    else
        echo -e "${BLUE}ℹ️ INFO${NC}: Homebrew detection skipped (not on macOS)"
    fi
}

# Test environment setup
test_environment_setup() {
    echo -e "\n${BLUE}Testing Environment Setup${NC}"
    
    # Test state directory creation
    local state_dir="$HOME/.config/claude-nvim"
    if [[ -d "$state_dir" ]]; then
        echo -e "${GREEN}✓ EXISTS${NC}: State directory at $state_dir"
    else
        echo -e "${YELLOW}⚠ MISSING${NC}: State directory not found at $state_dir"
    fi
    
    # Test state file
    local state_file="$state_dir/state.yaml"
    if [[ -f "$state_file" ]]; then
        echo -e "${GREEN}✓ EXISTS${NC}: State file at $state_file"
        
        # Test state file format
        if command -v yq &>/dev/null; then
            if yq eval '.' "$state_file" &>/dev/null; then
                echo -e "${GREEN}✓ VALID${NC}: State file is valid YAML"
            else
                echo -e "${RED}✗ INVALID${NC}: State file is not valid YAML"
            fi
        fi
    else
        echo -e "${YELLOW}⚠ MISSING${NC}: State file not found at $state_file"
    fi
}

# Main test runner
run_integration_tests() {
    echo -e "${BLUE}🔬 Starting Integration Tests${NC}\n"
    
    # Run all tests
    test_script_execution
    test_os_detection_integration
    test_argument_parsing
    test_state_management
    test_dependency_checks
    test_checksum_functionality
    test_homebrew_detection
    test_environment_setup
    
    # Print summary
    echo -e "\n${BLUE}📊 Integration Test Summary${NC}"
    echo -e "Total tests: $TESTS_TOTAL"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}🎉 All integration tests passed!${NC}"
        exit 0
    else
        echo -e "\n${RED}💥 Some integration tests failed!${NC}"
        exit 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_integration_tests
fi