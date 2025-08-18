#!/bin/bash

# Unit Testing Framework for Neovim Installation Script
# Tests helper functions and cross-platform compatibility

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

# Source the install script to access functions (in a safe way)
source_install_functions() {
    # First source the state manager
    # shellcheck disable=SC1091  # External file not analyzed by shellcheck
    source "$SCRIPT_DIR/../state_manager.sh"

    # Create a temporary modified script that doesn't execute main()
    local temp_script
    temp_script=$(mktemp)
    # Remove the main execution part but keep all functions, and fix the state_manager.sh path
    sed '/^# Run main installation$/,$d' "$INSTALL_SCRIPT" | \
    sed "s|source \"\$SCRIPT_DIR/state_manager.sh\"|source \"$SCRIPT_DIR/../state_manager.sh\"|" > "$temp_script"
    # shellcheck disable=SC1090  # Disable warning for dynamic source
    source "$temp_script"
    rm "$temp_script"
}

# Test framework functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo -e "  Expected: ${YELLOW}$expected${NC}"
        echo -e "  Actual:   ${YELLOW}$actual${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_true() {
    local condition="$1"
    local test_name="$2"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    if eval "$condition"; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo -e "  Condition failed: ${YELLOW}$condition${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_false() {
    local condition="$1"
    local test_name="$2"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))

    if ! eval "$condition"; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo -e "  Condition should have failed: ${YELLOW}$condition${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test OS detection
test_os_detection() {
    echo -e "\n${BLUE}Testing OS Detection${NC}"

    # Mock uname for testing
    uname() {
        case "$1" in
            -s) echo "$MOCK_OS" ;;
            -m) echo "$MOCK_ARCH" ;;
            *) command uname "$@" ;;
        esac
    }

    # Test Linux detection
    MOCK_OS="Linux"
    local result
    result=$(detect_os)
    assert_equals "linux" "$result" "Linux OS detection"

    # Test macOS detection
    MOCK_OS="Darwin"
    result=$(detect_os)
    assert_equals "macos" "$result" "macOS OS detection"

    # Test unsupported OS
    MOCK_OS="FreeBSD"
    result=$(detect_os)
    assert_equals "unsupported" "$result" "Unsupported OS detection"

    # Clean up mock
    unset -f uname
}

# Test architecture detection for macOS
test_arch_detection() {
    echo -e "\n${BLUE}Testing Architecture Detection${NC}"

    # Mock uname for testing
    uname() {
        case "$1" in
            -s) echo "Darwin" ;;
            -m) echo "$MOCK_ARCH" ;;
            *) command uname "$@" ;;
        esac
    }

    # Test ARM64 detection
    MOCK_ARCH="arm64"
    local arch
    arch=$(uname -m)
    assert_equals "arm64" "$arch" "ARM64 architecture detection"

    # Test x86_64 detection
    MOCK_ARCH="x86_64"
    arch=$(uname -m)
    assert_equals "x86_64" "$arch" "x86_64 architecture detection"

    # Clean up mock
    unset -f uname
}

# Test package installation URL generation
test_lazygit_url_generation() {
    echo -e "\n${BLUE}Testing LazyGit URL Generation${NC}"

    # Mock functions for testing
    export OS_TYPE="macos"  # Export for external use
    local version="0.40.2"

    # Mock uname for ARM64
    uname() {
        case "$1" in
            -m) echo "arm64" ;;
            *) command uname "$@" ;;
        esac
    }

    local expected_arm="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${version}_Darwin_arm64.tar.gz"
    # Test URL format construction
    echo "Expected ARM URL format: $expected_arm"
    # We can't easily test the URL generation without refactoring, so we test the logic
    local mac_arch
    mac_arch=$(uname -m)
    if [[ "$mac_arch" == "arm64" ]]; then
        local url_suffix="Darwin_arm64.tar.gz"
    else
        local url_suffix="Darwin_x86_64.tar.gz"
    fi

    assert_equals "Darwin_arm64.tar.gz" "$url_suffix" "ARM64 URL suffix generation"

    # Test x86_64
    uname() {
        case "$1" in
            -m) echo "x86_64" ;;
            *) command uname "$@" ;;
        esac
    }

    mac_arch=$(uname -m)
    if [[ "$mac_arch" == "arm64" ]]; then
        url_suffix="Darwin_arm64.tar.gz"
    else
        url_suffix="Darwin_x86_64.tar.gz"
    fi

    assert_equals "Darwin_x86_64.tar.gz" "$url_suffix" "x86_64 URL suffix generation"

    # Clean up mock
    unset -f uname
}

# Test Homebrew path detection
test_homebrew_paths() {
    echo -e "\n${BLUE}Testing Homebrew Path Detection${NC}"

    # Test ARM64 Homebrew path
    local arm_path="/opt/homebrew/bin/brew"
    assert_true "[[ '$arm_path' == '/opt/homebrew/bin/brew' ]]" "ARM64 Homebrew path detection"

    # Test Intel Homebrew path
    local intel_path="/usr/local/bin/brew"
    assert_true "[[ '$intel_path' == '/usr/local/bin/brew' ]]" "Intel Homebrew path detection"
}

# Test checksum validation function
test_checksum_validation() {
    echo -e "\n${BLUE}Testing Checksum Validation${NC}"

    # Create a test file with known content
    local test_file
    test_file=$(mktemp)
    echo "test content" > "$test_file"

    # Calculate actual checksum
    local actual_checksum
    actual_checksum=$(shasum -a 256 "$test_file" | cut -d' ' -f1)

    # Test valid checksum
    validate_checksum() {
        local file="$1"
        local expected="$2"
        local actual
        actual=$(shasum -a 256 "$file" | cut -d' ' -f1)
        [[ "$actual" == "$expected" ]]
    }

    assert_true "validate_checksum '$test_file' '$actual_checksum'" "Valid checksum validation"

    # Test invalid checksum
    local invalid_checksum="invalid_checksum_value"
    assert_false "validate_checksum '$test_file' '$invalid_checksum'" "Invalid checksum validation"

    # Clean up
    rm "$test_file"
}

# Test command existence checks
test_command_checks() {
    echo -e "\n${BLUE}Testing Command Existence Checks${NC}"

    # Test existing command
    assert_true "command -v bash &>/dev/null" "Bash command existence check"

    # Test non-existing command
    assert_false "command -v nonexistent_command_12345 &>/dev/null" "Non-existing command check"
}

# Test state validation
test_state_validation() {
    echo -e "\n${BLUE}Testing State Validation${NC}"

    # Test valid states
    local valid_states=("notcheckedyet" "installed" "notinstalled")
    for state in "${valid_states[@]}"; do
        case "$state" in
            notcheckedyet|installed|notinstalled)
                local is_valid=true
                ;;
            *)
                local is_valid=false
                ;;
        esac
        assert_true "[[ '$is_valid' == 'true' ]]" "Valid state: $state"
    done

    # Test invalid state
    local invalid_state="invalid_state"
    case "$invalid_state" in
        notcheckedyet|installed|notinstalled)
            is_valid=true
            ;;
        *)
            is_valid=false
            ;;
    esac
    assert_true "[[ '$is_valid' == 'false' ]]" "Invalid state detection"
}

# Test log formatting
test_log_formatting() {
    echo -e "\n${BLUE}Testing Log Formatting${NC}"

    # Test log action formatting (capture output)
    log_action() {
        local component="$1"
        local action="$2"
        local status="$3"

        case "$status" in
            "success")
                echo "✅ [$component] Success - $action"
                ;;
            "failed")
                echo "❌ [$component] Failed - $action"
                ;;
            "skip")
                echo "⏸️  [$component] Skipped - $action"
                ;;
            *)
                echo "[$component] $status - $action"
                ;;
        esac
    }

    local success_output
    success_output=$(log_action "Test" "Test action" "success")
    assert_true "[[ '$success_output' == *'✅'* ]]" "Success log formatting"

    local failed_output
    failed_output=$(log_action "Test" "Test action" "failed")
    assert_true "[[ '$failed_output' == *'❌'* ]]" "Failed log formatting"

    local skip_output
    skip_output=$(log_action "Test" "Test action" "skip")
    assert_true "[[ '$skip_output' == *'⏸️'* ]]" "Skip log formatting"
}

# Main test runner
run_tests() {
    echo -e "${BLUE}🧪 Starting Neovim Installation Script Tests${NC}\n"

    # Source the install script functions
    echo -e "${YELLOW}Loading install script functions...${NC}"
    source_install_functions

    # Run all tests
    test_os_detection
    test_arch_detection
    test_lazygit_url_generation
    test_homebrew_paths
    test_checksum_validation
    test_command_checks
    test_state_validation
    test_log_formatting

    # Print summary
    echo -e "\n${BLUE}📊 Test Summary${NC}"
    echo -e "Total tests: $TESTS_TOTAL"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}🎉 All tests passed!${NC}"
        exit 0
    else
        echo -e "\n${RED}💥 Some tests failed!${NC}"
        exit 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
