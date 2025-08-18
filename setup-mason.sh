#!/bin/bash

# Mason LSP Server Setup Script
# This script ensures all Mason LSP servers are installed properly
# Especially useful for macOS ARM systems where headless installation may fail

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Mason LSP Server Setup${NC}"
echo -e "${BLUE}=========================${NC}"

# Check if Neovim is available
if ! command -v nvim &> /dev/null; then
    echo -e "${RED}❌ Neovim not found. Please install Neovim first.${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Starting Mason LSP server installation...${NC}"

# Create a temporary Neovim script for Mason setup
MASON_SCRIPT=$(cat << 'EOF'
-- Mason setup script
local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
    print("Mason not available")
    vim.cmd("qall!")
    return
end

local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_ok then
    print("Mason-lspconfig not available")
    vim.cmd("qall!")
    return
end

print("Mason available, starting installation...")

-- List of servers to ensure are installed
local servers = {
    "lua_ls",           -- Lua (Neovim config)
    "rust_analyzer",    -- Rust
    "ts_ls",            -- TypeScript/JavaScript
    "gopls",           -- Go
    "pyright",         -- Python
    "bashls",          -- Bash shell scripts
    "marksman",        -- Markdown
    "jsonls",          -- JSON
    "taplo",           -- TOML (Cargo.toml)
    "html",            -- HTML
    "cssls",           -- CSS
    "yamlls",          -- YAML
    "dockerls",        -- Docker
    "terraformls",     -- Terraform (HCL)
}

local installed_count = 0
local failed_count = 0

-- Check which servers are already installed
local mason_registry = require("mason-registry")

for _, server in ipairs(servers) do
    print("Checking " .. server .. "...")
    
    local package_name = server
    local package = mason_registry.get_package(package_name)
    
    if package:is_installed() then
        print("✓ " .. server .. " already installed")
        installed_count = installed_count + 1
    else
        print("Installing " .. server .. "...")
        local success = pcall(function()
            package:install():once("closed", function()
                if package:is_installed() then
                    print("✓ " .. server .. " installed successfully")
                    installed_count = installed_count + 1
                else
                    print("✗ " .. server .. " installation failed")
                    failed_count = failed_count + 1
                end
            end)
        end)
        
        if not success then
            print("✗ Failed to start installation for " .. server)
            failed_count = failed_count + 1
        end
    end
end

print("Installation summary:")
print("- Attempted: " .. #servers)
print("- Installed: " .. installed_count)
print("- Failed: " .. failed_count)

-- Wait longer for installations to complete
vim.cmd("sleep 30")

vim.cmd("qall!")
EOF
)

# Write the script to a temporary file
TEMP_SCRIPT=$(mktemp /tmp/mason_setup_XXXXXX.lua)
echo "$MASON_SCRIPT" > "$TEMP_SCRIPT"

# Cleanup function
cleanup() {
    rm -f "$TEMP_SCRIPT"
}
trap cleanup EXIT

# Run the Mason setup
echo -e "${YELLOW}🚀 Running Mason installation (this may take a few minutes)...${NC}"

if nvim --headless -S "$TEMP_SCRIPT" 2>&1; then
    echo -e "${GREEN}✅ Mason setup completed!${NC}"
    echo -e "${GREEN}📚 You can verify installations by running: nvim -c ':Mason'${NC}"
else
    echo -e "${YELLOW}⚠️  Automated installation may have failed.${NC}"
    echo -e "${YELLOW}💡 Try running manually: nvim -c ':Mason' to install servers interactively${NC}"
fi

echo -e "${BLUE}🏁 Mason setup script finished${NC}"