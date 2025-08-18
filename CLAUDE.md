# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Neovim configuration project aimed at creating a feature-rich, performant setup with the following requirements:
- Monokai theme with JetBrains fonts
- File browsing capabilities  
- Terminal integration
- Git workflow integration
- LSP support for syntax features
- Optimized for use with Claude CLI, Alacritty, Bash, Neovim, and Tmux

## Language Support

Daniel's primary development stack includes:
- **Go** (golang) - Web services and CLI tools
- **Rust** (rustlang with Cargo) - System programming and performance-critical applications
- **TypeScript/JavaScript** (Node.js with npm) - Frontend development
- **Python3** (with uv for package management) - Scripting and data work
- **Lua** - Neovim configuration
- **Markdown** - Documentation
- **Bash** - Shell scripting

Additional supported languages and formats:
- **HTML/CSS** - Web development
- **JSON/YAML** - Configuration files with schema validation
- **TOML** - Rust/Cargo configuration
- **Docker** - Containerization (Dockerfile)
- **Terraform (HCL)** - Infrastructure as code
- **Git** - Version control files

Perl and Ruby providers are disabled as they're not used.

## Configuration Structure

The Neovim configuration should be organized in `~/.config/nvim/` with:
- `init.lua` - Main entry point
- `lua/` directory containing modular configuration files
- Plugin management (likely using lazy.nvim or packer.nvim)

## Development Commands

### Idempotent Installation
The project uses an idempotent installation system with state management:

```bash
# Run full installation (safe to run multiple times)
./install.sh

# Check current installation state
./install.sh --show-state

# Reset state for testing
./install.sh --reset-state

# Install specific components only
./install.sh --skip-fonts --skip-deps
```

### State Management
Installation state is tracked in `~/.config/claude-nvim/state.yaml` using **yq** for YAML processing:
- **yq** - YAML processor for reading/writing state (available at `/home/daniel/go/bin/yq`)
- **States**: `notcheckedyet`, `installed`, `notinstalled`
- **Components tracked**: neovim_check, git_install, ripgrep_install, fd_install, fzf_install, node_install, python_install, fonts_install, config_backup, config_install, lazyvim_install, plugins_install, tmux_install

### Testing Configuration
```bash
# Test configuration syntax
nvim --headless -c "quit"

# Check for errors
nvim -c "checkhealth"

# Test state management
./install.sh --show-state
```

## Key Requirements from README

1. **Visual Setup**: Implement Monokai Pro theme with JetBrains Mono font
2. **Documentation**: Create comprehensive usage guide covering:
   - Leader key configuration (Space as leader)
   - File browsing commands (Neo-tree, Telescope)
   - Terminal usage (ToggleTerm integration)
   - Buffer management
   - File creation and navigation
3. **Workflow Integration**: 
   - Tmux integration for Claude CLI workflow
   - Git commands from within Neovim (LazyGit, Gitsigns, Fugitive)
   - LSP configuration for responsive development

## Installation Features

The install script (`install.sh`) provides flexible installation with these key flags:
- `--skip-fonts` - Skip JetBrains Mono font installation
- `--skip-deps` - Skip dependency installations (ripgrep, fd, fzf)
- `--skip-node/python/rust` - Skip language-specific installations
- `--with-tmux` - Install optimized tmux configuration
- `--skip-backup` - Skip backing up existing configuration

## Essential Keybindings (Space as Leader)

### File Operations
- `<leader>ff` - Find files with Telescope
- `<leader>fg` - Live grep across project
- `<leader>e` - Toggle Neo-tree file explorer

### Development
- `gd` - Go to definition
- `K` - Show hover documentation
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol
- `<leader>f` - Format current file

### Terminal & Git
- `<leader>tt` - Toggle floating terminal
- `<leader>lg` - Open LazyGit interface
- `<leader>hs` - Stage git hunk

### Navigation
- `Shift+h/l` - Previous/next buffer
- `<leader>bd` - Delete buffer
- `Ctrl+h/j/k/l` - Window navigation

## Tmux Integration Workflow

Optimized for Claude CLI development:
1. **Session**: `tmux new -s dev`
2. **Split panes**: `Ctrl+a |` (horizontal), `Ctrl+a -` (vertical)
3. **Navigate**: `Ctrl+a h/j/k/l` or `Alt+Arrow Keys`
4. **Resize**: `Ctrl+a H/J/K/L`
5. **Quick window switching**: `Ctrl+Shift+Left/Right`

## LSP Configuration

Supports these languages with full LSP integration:
- **Go**: `gopls` with formatting, linting, debugging
- **Rust**: `rust_analyzer` with Cargo integration, Clippy
- **TypeScript**: `ts_ls` with InlayHints, auto-imports
- **Python**: `pyright` with type checking, uv support
- **Lua**: `lua_ls` with Neovim API integration

## Architecture Overview

```
nvim/
├── init.lua                    # Main configuration entry
├── lua/
│   ├── config/                 # Core settings
│   │   ├── options.lua        # Editor options
│   │   ├── keymaps.lua        # Key bindings
│   │   └── autocmds.lua       # Auto commands
│   └── plugins/               # Plugin configurations
│       ├── colorscheme.lua    # Monokai Pro theme
│       ├── lsp.lua           # Language servers
│       ├── telescope.lua     # Fuzzy finder
│       ├── neo-tree.lua      # File explorer
│       ├── git.lua           # Git integration
│       ├── terminal.lua      # Terminal management
│       ├── fzf-lua.lua       # Alternative finder
│       └── ui.lua            # UI enhancements
└── tmux.conf                  # Tmux configuration
```

## Architecture Decisions

When implementing this configuration:
- Use Lua for all configuration (avoid VimScript where possible)
- Modularize configuration into logical components
- Implement lazy loading for performance
- Ensure compatibility with latest Neovim stable version

## Plugin Recommendations

Essential plugins to consider:
- `folke/lazy.nvim` - Plugin manager
- `nvim-tree/nvim-tree.lua` or `nvim-neo-tree/neo-tree.nvim` - File explorer
- `nvim-telescope/telescope.nvim` - Fuzzy finder
- `neovim/nvim-lspconfig` - LSP configuration
- `lewis6991/gitsigns.nvim` and `tpope/vim-fugitive` - Git integration
- `akinsho/toggleterm.nvim` - Terminal management
- Theme plugin supporting Monokai