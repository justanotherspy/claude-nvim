# Makefile for Neovim Configuration Installation Testing
# Provides comprehensive testing, validation, and quality assurance

.DEFAULT_GOAL := help
.PHONY: help test test-unit test-integration test-all lint syntax-check validate-checksums clean install-dev-deps

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Variables
INSTALL_SCRIPT := install.sh
STATE_MANAGER := state_manager.sh
TEST_DIR := tests
UNIT_TESTS := $(TEST_DIR)/test_helpers.sh
INTEGRATION_TESTS := $(TEST_DIR)/test_integration.sh

# OS Detection
OS := $(shell uname -s)
ARCH := $(shell uname -m)

# Homebrew paths based on architecture (macOS)
ifeq ($(OS),Darwin)
    ifeq ($(ARCH),arm64)
        BREW_PATH := /opt/homebrew/bin/brew
        HOMEBREW_PREFIX := /opt/homebrew
    else
        BREW_PATH := /usr/local/bin/brew
        HOMEBREW_PREFIX := /usr/local
    endif
endif

## Display this help message
help:
	@echo "$(BLUE)🛠️  Neovim Configuration Testing & Validation$(NC)"
	@echo ""
	@echo "$(YELLOW)Usage:$(NC) make [target]"
	@echo ""
	@echo "$(YELLOW)Testing Targets:$(NC)"
	@echo "  test              - Run all tests (unit + integration)"
	@echo "  test-unit         - Run unit tests for helper functions"
	@echo "  test-integration  - Run integration tests"
	@echo "  test-homebrew     - Test Homebrew installation and detection (macOS only)"
	@echo ""
	@echo "$(YELLOW)Validation Targets:$(NC)"
	@echo "  lint              - Run shellcheck on all shell scripts"
	@echo "  syntax-check      - Validate bash syntax"
	@echo "  validate-checksums - Verify download checksums"
	@echo "  security-scan     - Scan for security issues"
	@echo ""
	@echo "$(YELLOW)Development Targets:$(NC)"
	@echo "  install-dev-deps  - Install development dependencies"
	@echo "  clean             - Clean test artifacts and temporary files"
	@echo "  show-env          - Show environment information"
	@echo ""
	@echo "$(YELLOW)CI/CD Targets:$(NC)"
	@echo "  ci                - Run full CI pipeline"
	@echo "  pre-commit        - Run pre-commit checks"
	@echo ""
	@echo "$(BLUE)Environment:$(NC) $(OS) $(ARCH)"
ifeq ($(OS),Darwin)
	@echo "$(BLUE)Homebrew Path:$(NC) $(BREW_PATH)"
endif

## Run all tests
test: test-unit test-integration
	@echo "$(GREEN)✅ All tests completed successfully!$(NC)"

## Run unit tests
test-unit:
	@echo "$(BLUE)🧪 Running unit tests...$(NC)"
	@if [ -f "$(UNIT_TESTS)" ]; then \
		chmod +x $(UNIT_TESTS) && $(UNIT_TESTS); \
	else \
		echo "$(RED)❌ Unit tests not found at $(UNIT_TESTS)$(NC)"; \
		exit 1; \
	fi

## Run integration tests
test-integration:
	@echo "$(BLUE)🔬 Running integration tests...$(NC)"
	@if [ -f "$(INTEGRATION_TESTS)" ]; then \
		chmod +x $(INTEGRATION_TESTS) && $(INTEGRATION_TESTS); \
	else \
		echo "$(RED)❌ Integration tests not found at $(INTEGRATION_TESTS)$(NC)"; \
		exit 1; \
	fi

## Test Homebrew installation and detection (macOS only)
test-homebrew:
ifeq ($(OS),Darwin)
	@echo "$(BLUE)🍺 Testing Homebrew installation and detection...$(NC)"
	@echo "Architecture: $(ARCH)"
	@echo "Expected Homebrew path: $(BREW_PATH)"
	@if [ -f "$(BREW_PATH)" ]; then \
		echo "$(GREEN)✅ Homebrew found at $(BREW_PATH)$(NC)"; \
		$(BREW_PATH) --version; \
	else \
		echo "$(YELLOW)⚠️  Homebrew not found at $(BREW_PATH)$(NC)"; \
		echo "$(BLUE)Testing Homebrew installation...$(NC)"; \
		echo "Would install with: /bin/bash -c \"\$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""; \
	fi
	@echo "$(BLUE)Testing PATH configuration...$(NC)"
	@if echo $$PATH | grep -q "$(HOMEBREW_PREFIX)/bin"; then \
		echo "$(GREEN)✅ Homebrew in PATH$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Homebrew not in PATH$(NC)"; \
		echo "$(BLUE)Would add: export PATH=\"$(HOMEBREW_PREFIX)/bin:\$$PATH\"$(NC)"; \
	fi
else
	@echo "$(BLUE)ℹ️  Homebrew tests skipped (not on macOS)$(NC)"
endif

## Run shellcheck linting
lint:
	@echo "$(BLUE)🔍 Running ShellCheck linting...$(NC)"
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "$(BLUE)Checking $(INSTALL_SCRIPT)...$(NC)"; \
		shellcheck -e SC1091 -e SC2034 $(INSTALL_SCRIPT) || true; \
		echo "$(BLUE)Checking $(STATE_MANAGER)...$(NC)"; \
		shellcheck -e SC1091 -e SC2034 $(STATE_MANAGER) || true; \
		find $(TEST_DIR) -name "*.sh" -exec echo "$(BLUE)Checking {}...$(NC)" \; -exec shellcheck {} \; || true; \
	else \
		echo "$(YELLOW)⚠️  ShellCheck not installed. Install with:$(NC)"; \
		echo "  Linux: apt install shellcheck"; \
		echo "  macOS: brew install shellcheck"; \
		exit 1; \
	fi

## Validate bash syntax
syntax-check:
	@echo "$(BLUE)📝 Validating bash syntax...$(NC)"
	@echo "$(BLUE)Checking $(INSTALL_SCRIPT)...$(NC)"
	@bash -n $(INSTALL_SCRIPT) && echo "$(GREEN)✅ $(INSTALL_SCRIPT) syntax OK$(NC)" || (echo "$(RED)❌ $(INSTALL_SCRIPT) syntax error$(NC)" && exit 1)
	@echo "$(BLUE)Checking $(STATE_MANAGER)...$(NC)"
	@bash -n $(STATE_MANAGER) && echo "$(GREEN)✅ $(STATE_MANAGER) syntax OK$(NC)" || (echo "$(RED)❌ $(STATE_MANAGER) syntax error$(NC)" && exit 1)
	@find $(TEST_DIR) -name "*.sh" -exec echo "$(BLUE)Checking {}...$(NC)" \; -exec bash -n {} \; -exec echo "$(GREEN)✅ {} syntax OK$(NC)" \;

## Validate YAML files (workflows, configs, etc.)
validate-yaml:
	@echo "$(BLUE)📋 Validating YAML files...$(NC)"
	@if command -v yq >/dev/null 2>&1; then \
		echo "$(BLUE)Checking GitHub workflow files...$(NC)"; \
		for file in .github/workflows/*.yml .github/workflows/*.yaml; do \
			if [ -f "$$file" ] && [ "$$file" != ".github/workflows/*.yml" ] && [ "$$file" != ".github/workflows/*.yaml" ]; then \
				echo -n "$(BLUE)Validating $$(basename $$file)... $(NC)"; \
				if yq eval '.' "$$file" > /dev/null 2>&1; then \
					echo "$(GREEN)✅$(NC)"; \
				else \
					echo "$(RED)❌$(NC)"; \
					echo "$(RED)Error in $$file:$(NC)"; \
					yq eval '.' "$$file" 2>&1 | head -10; \
					exit 1; \
				fi; \
			fi; \
		done; \
		echo "$(BLUE)Checking other YAML files...$(NC)"; \
		for file in .github/*.yml .github/*.yaml *.yml *.yaml; do \
			if [ -f "$$file" ] && [ "$$(basename $$file)" != "state.yaml" ] && [ "$$file" != ".github/*.yml" ] && [ "$$file" != ".github/*.yaml" ] && [ "$$file" != "*.yml" ] && [ "$$file" != "*.yaml" ]; then \
				echo -n "$(BLUE)Validating $$(basename $$file)... $(NC)"; \
				if yq eval '.' "$$file" > /dev/null 2>&1; then \
					echo "$(GREEN)✅$(NC)"; \
				else \
					echo "$(RED)❌$(NC)"; \
					echo "$(RED)Error in $$file:$(NC)"; \
					yq eval '.' "$$file" 2>&1 | head -10; \
					exit 1; \
				fi; \
			fi; \
		done; \
		echo "$(GREEN)✅ All YAML files are valid$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  yq not installed. Install with:$(NC)"; \
		echo "  Linux: wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq"; \
		echo "  macOS: brew install yq"; \
		exit 1; \
	fi

## Validate GitHub Actions workflows specifically
validate-workflows: validate-yaml
	@echo "$(BLUE)🔄 Validating GitHub Actions workflows...$(NC)"
	@if command -v yq >/dev/null 2>&1; then \
		for file in .github/workflows/*.yml .github/workflows/*.yaml; do \
			if [ -f "$$file" ]; then \
				echo "$(BLUE)Checking workflow: $$(basename $$file)$(NC)"; \
				echo -n "  Structure validation... "; \
				if yq eval '.name' "$$file" > /dev/null 2>&1; then \
					echo "$(GREEN)✅$(NC)"; \
				else \
					echo "$(RED)❌ Missing 'name' field$(NC)"; \
				fi; \
				echo -n "  Checking 'on' trigger... "; \
				if yq eval '.on' "$$file" > /dev/null 2>&1; then \
					echo "$(GREEN)✅$(NC)"; \
				else \
					echo "$(RED)❌ Missing 'on' trigger$(NC)"; \
				fi; \
				echo -n "  Checking jobs... "; \
				if yq eval '.jobs' "$$file" > /dev/null 2>&1; then \
					JOB_COUNT=$$(yq eval '.jobs | keys | length' "$$file"); \
					echo "$(GREEN)✅ ($$JOB_COUNT job(s))$(NC)"; \
				else \
					echo "$(RED)❌ No jobs defined$(NC)"; \
				fi; \
				echo -n "  Checking for deprecated actions... "; \
				if grep -q "actions/checkout@v[12]" "$$file" 2>/dev/null; then \
					echo "$(YELLOW)⚠️  Using old checkout version$(NC)"; \
				else \
					echo "$(GREEN)✅$(NC)"; \
				fi; \
			fi; \
		done; \
		echo "$(GREEN)✅ Workflow validation complete$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  yq not installed. Install with:$(NC)"; \
		echo "  Linux: wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq"; \
		echo "  macOS: brew install yq"; \
		exit 1; \
	fi

## Validate download checksums
validate-checksums:
	@echo "$(BLUE)🔐 Validating download checksums...$(NC)"
	@if command -v shasum >/dev/null 2>&1; then \
		echo "$(GREEN)✅ shasum available for checksum validation$(NC)"; \
	elif command -v sha256sum >/dev/null 2>&1; then \
		echo "$(GREEN)✅ sha256sum available for checksum validation$(NC)"; \
	else \
		echo "$(RED)❌ No SHA256 tool available (shasum or sha256sum)$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Testing checksum validation function...$(NC)"
	@# Create test file with known content
	@echo "test content for checksum" > /tmp/test_checksum.txt
	@if command -v shasum >/dev/null 2>&1; then \
		CHECKSUM=$$(shasum -a 256 /tmp/test_checksum.txt | cut -d' ' -f1); \
		echo "$(BLUE)Test file checksum: $$CHECKSUM$(NC)"; \
		VERIFY_CHECKSUM=$$(shasum -a 256 /tmp/test_checksum.txt | cut -d' ' -f1); \
		if [ "$$CHECKSUM" = "$$VERIFY_CHECKSUM" ]; then \
			echo "$(GREEN)✅ Checksum validation working$(NC)"; \
		else \
			echo "$(RED)❌ Checksum validation failed$(NC)"; \
			exit 1; \
		fi; \
	fi
	@rm -f /tmp/test_checksum.txt

## Scan for security issues
security-scan:
	@echo "$(BLUE)🔒 Running security scan...$(NC)"
	@echo "$(BLUE)Checking for potential security issues...$(NC)"
	@# Check for hardcoded secrets or URLs
	@if grep -r "password\|secret\|token" $(INSTALL_SCRIPT) $(STATE_MANAGER); then \
		echo "$(YELLOW)⚠️  Found potential secrets (review manually)$(NC)"; \
	else \
		echo "$(GREEN)✅ No obvious secrets found$(NC)"; \
	fi
	@# Check for curl without verification
	@if grep -n "curl.*-k\|curl.*--insecure" $(INSTALL_SCRIPT); then \
		echo "$(RED)❌ Found insecure curl usage$(NC)"; \
		exit 1; \
	else \
		echo "$(GREEN)✅ No insecure curl usage found$(NC)"; \
	fi
	@# Check for eval usage
	@if grep -n "eval.*\$$" $(INSTALL_SCRIPT) $(STATE_MANAGER); then \
		echo "$(YELLOW)⚠️  Found eval usage (review for injection risks)$(NC)"; \
	else \
		echo "$(GREEN)✅ No risky eval usage found$(NC)"; \
	fi

## Install development dependencies
install-dev-deps:
	@echo "$(BLUE)📦 Installing development dependencies...$(NC)"
ifeq ($(OS),Darwin)
	@if [ ! -f "$(BREW_PATH)" ]; then \
		echo "$(BLUE)Installing Homebrew...$(NC)"; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
	fi
	@$(BREW_PATH) install shellcheck || echo "$(YELLOW)⚠️  ShellCheck already installed or failed$(NC)"
	@$(BREW_PATH) install yq || echo "$(YELLOW)⚠️  yq already installed or failed$(NC)"
else ifeq ($(OS),Linux)
	@if command -v apt >/dev/null 2>&1; then \
		echo "$(BLUE)Installing via apt...$(NC)"; \
		sudo apt update; \
		sudo apt install -y shellcheck; \
		echo "$(BLUE)Installing Go-based yq...$(NC)"; \
		sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq; \
		sudo chmod +x /usr/local/bin/yq; \
	else \
		echo "$(YELLOW)⚠️  Please install shellcheck and yq manually$(NC)"; \
	fi
endif

## Clean test artifacts and temporary files
clean:
	@echo "$(BLUE)🧹 Cleaning up...$(NC)"
	@rm -f /tmp/test_checksum.txt
	@rm -f /tmp/nvim_test_*
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name "*.log" -delete 2>/dev/null || true
	@echo "$(GREEN)✅ Cleanup completed$(NC)"

## Show environment information
show-env:
	@echo "$(BLUE)🌍 Environment Information$(NC)"
	@echo "OS: $(OS)"
	@echo "Architecture: $(ARCH)"
	@echo "Shell: $$SHELL"
	@echo "User: $$USER"
	@echo "Home: $$HOME"
	@echo "PATH: $$PATH"
ifeq ($(OS),Darwin)
	@echo "Homebrew Path: $(BREW_PATH)"
	@echo "Homebrew Prefix: $(HOMEBREW_PREFIX)"
endif
	@echo ""
	@echo "$(BLUE)Available Commands:$(NC)"
	@echo -n "git: "; command -v git >/dev/null && echo "$(GREEN)✅$(NC)" || echo "$(RED)❌$(NC)"
	@echo -n "curl: "; command -v curl >/dev/null && echo "$(GREEN)✅$(NC)" || echo "$(RED)❌$(NC)"
	@echo -n "yq: "; command -v yq >/dev/null && echo "$(GREEN)✅$(NC)" || echo "$(RED)❌$(NC)"
	@echo -n "shellcheck: "; command -v shellcheck >/dev/null && echo "$(GREEN)✅$(NC)" || echo "$(RED)❌$(NC)"

## Run full CI pipeline
ci: syntax-check lint test security-scan
	@echo "$(GREEN)🎉 CI pipeline completed successfully!$(NC)"

## Run pre-commit checks
pre-commit: syntax-check lint
	@echo "$(GREEN)✅ Pre-commit checks passed!$(NC)"

# Test that requires arguments - example of parameterized tests
test-with-flags:
	@echo "$(BLUE)🏃 Testing with various flags...$(NC)"
	@./$(INSTALL_SCRIPT) --help >/dev/null && echo "$(GREEN)✅ --help works$(NC)" || echo "$(RED)❌ --help failed$(NC)"
	@./$(INSTALL_SCRIPT) --show-state >/dev/null && echo "$(GREEN)✅ --show-state works$(NC)" || echo "$(RED)❌ --show-state failed$(NC)"
	@./$(INSTALL_SCRIPT) --skip-tmux --show-state >/dev/null && echo "$(GREEN)✅ --skip-tmux works$(NC)" || echo "$(RED)❌ --skip-tmux failed$(NC)"