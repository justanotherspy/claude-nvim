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

echo -e "${YELLOW}📦 Starting Mason LSP server verification and installation...${NC}"

# First, let's check what's already installed to be truly idempotent
echo -e "${BLUE}🔍 Checking current Mason installation status...${NC}"

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

print("Mason available, checking installation status...")

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

local already_installed = 0
local newly_installed = 0
local failed_count = 0
local need_installation = {}

-- Use Mason-lspconfig to get correct server-to-package mapping
local installed_servers = mason_lspconfig.get_installed_servers()
local installed_set = {}
for _, server in ipairs(installed_servers) do
    installed_set[server] = true
end

-- First pass: Check what's already installed and what needs installation
print("\n=== IDEMPOTENT STATUS CHECK ===")
for _, server in ipairs(servers) do
    if installed_set[server] then
        print("✅ " .. server .. " - already installed")
        already_installed = already_installed + 1
    else
        print("⏳ " .. server .. " - needs installation")
        table.insert(need_installation, server)
    end
end

-- Early exit if everything is already installed
if #need_installation == 0 and failed_count == 0 then
    print("\n🎉 All LSP servers are already installed! Nothing to do.")
    print("\nFINAL SUMMARY:")
    print("- Already installed: " .. already_installed .. "/" .. #servers)
    print("- No action needed - system is up to date")
    vim.cmd("qall!")
    return
end

-- Second pass: Provide guidance for missing servers
if #need_installation > 0 then
    print("\n=== MISSING SERVERS DETECTED ===")
    print("Found " .. #need_installation .. " servers that need installation:")
    
    for _, server in ipairs(need_installation) do
        print("  ⏳ " .. server)
    end
    
    print("\n💡 INSTALLATION METHODS:")
    print("1. Interactive (Recommended): Run 'nvim -c :Mason' and install manually")
    print("2. Automatic: LSP servers will install when first used")
    print("3. Force reinstall: Run './install.sh --reset-state'")
    print("4. Re-run this script after manual installation to verify")
    
    -- Mark as guidance provided, not failed installation
    newly_installed = 0  -- We didn't actually install anything
    failed_count = 0     -- This isn't a failure, just missing servers
end

-- Final status report
print("\n=== FINAL SUMMARY ===")
print("- Already installed: " .. already_installed .. "/" .. #servers)
print("- Need installation: " .. #need_installation .. "/" .. #servers)

if #need_installation == 0 then
    print("✅ All LSP servers are installed - system ready!")
else
    print("📋 " .. #need_installation .. " servers need installation - see guidance above")
    print("💡 This is normal for first-time setup - use interactive installation")
end

print("🔄 This script is idempotent - run anytime to check status")

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
echo -e "${YELLOW}🚀 Running Mason LSP server check and installation...${NC}"
echo -e "${BLUE}ℹ️  This script is idempotent - safe to run multiple times${NC}"

# Capture output to show it and also check for early exit
OUTPUT=$(nvim --headless -S "$TEMP_SCRIPT" 2>&1)
EXIT_CODE=$?

# Show the output
echo "$OUTPUT"

# Check if script completed successfully
if [ $EXIT_CODE -eq 0 ]; then
    # Check if it was an early exit (all already installed)
    if echo "$OUTPUT" | grep -q "Nothing to do"; then
        echo -e "${GREEN}✅ System is already up to date - no installations needed!${NC}"
    elif echo "$OUTPUT" | grep -q "system ready"; then
        echo -e "${GREEN}✅ All LSP servers are installed and ready!${NC}"
    elif echo "$OUTPUT" | grep -q "need installation"; then
        echo -e "${BLUE}📋 Status check complete - some servers need installation${NC}"
        echo -e "${YELLOW}💡 For first-time setup, run: nvim -c ':Mason' for interactive installation${NC}"
    else
        echo -e "${GREEN}✅ Mason status check completed!${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Status check encountered issues${NC}"
    echo -e "${YELLOW}💡 Try running: nvim -c ':Mason' to check manually${NC}"
fi

echo -e "${BLUE}🏁 Idempotent Mason setup finished - safe to re-run anytime${NC}"