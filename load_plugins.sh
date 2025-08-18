#!/bin/bash

echo "🔄 Loading all Neovim plugins and LSP servers..."

# Start Neovim and let it load plugins
echo "Step 1: Starting Neovim to trigger plugin loading..."
nvim +q

# Open Neovim with Mason to install LSP servers
echo "Step 2: Opening Mason to install LSP servers..."
echo "In Neovim, run:"
echo "  :Mason"
echo "  Press 'i' to install these language servers:"
echo "  - lua_ls (Lua)"
echo "  - rust_analyzer (Rust)"
echo "  - ts_ls (TypeScript)"
echo "  - gopls (Go)"
echo "  - pyright (Python)"
echo "  - bashls (Bash)"
echo "  - marksman (Markdown)"
echo "  - jsonls (JSON)"
echo "  - taplo (TOML)"
echo "  - html (HTML)"
echo "  - cssls (CSS)"
echo "  - yamlls (YAML)"
echo "  - dockerls (Docker)"
echo "  - terraformls (Terraform)"
echo "  - actionlint (GitHub Actions linter)"
echo "  - autopep8 (Python formatter)"

echo ""
echo "📋 Manual Steps:"
echo "1. Run: nvim"
echo "2. Type: :Mason"
echo "3. Navigate to servers and install the ones you need"
echo "4. Type: :TSUpdate to install treesitter parsers"
echo "5. Type: :checkhealth to verify everything works"

echo ""
echo "🎯 Quick commands:"
echo "nvim -c 'Mason' - Open Mason directly"
echo "nvim -c 'TSUpdate' - Update treesitter parsers"
echo "nvim -c 'Lazy sync' - Sync all plugins"
