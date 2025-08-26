# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Neovim configuration project aimed at creating a feature-rich, performant setup with the following requirements:
- Monokai theme with JetBrains fonts
- File browsing capabilities  
- Terminal integration
- Git workflow integration
- LSP support for syntax features
- Cross-platform support (Linux and macOS)
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

### Cross-Platform Installation
The project uses an idempotent, cross-platform installation system with automatic OS detection:

```bash
# Run full installation (works on Linux and macOS)
./install_nvim.sh

# Check current installation state
./install_nvim.sh --show-state

# Reset state for testing
./install_nvim.sh --reset-state

# Install specific components only
./install_nvim.sh --skip-fonts --skip-deps
```

### Testing with Makefile
**IMPORTANT**: Use the Makefile for testing installation as a sanity check. The install script is idempotent and the repository is the source of truth for configuration:

```bash
# Deploy latest repo config to local machine (primary testing method)
make install

# Test installation with various flags and configurations
make test-install

# Run all validation checks
make test
```

The `make install` target ensures that any changes made to the repository configuration files are properly deployed to the local machine, preventing configuration drift.

**Platform Detection:**
- Automatically detects Linux vs macOS
- Uses appropriate package manager (apt vs brew)
- Handles platform-specific installation paths and requirements

### State Management
Installation state is tracked in `~/.config/claude-nvim/state.yaml` using **yq** for YAML processing:
- **yq/jq** - YAML/JSON processors installed automatically for state management
- **States**: `notcheckedyet`, `installed`, `notinstalled`
- **Components tracked**: neovim_check, git_install, yq_install, jq_install, ripgrep_install, fd_install, fzf_install, node_install, python_install, fonts_install, config_backup, config_install, lazyvim_install, plugins_install, lazygit_install, tmux_install

### Key Features
- **Auto-checking**: All `notcheckedyet` components are automatically processed on each run
- **Config drift prevention**: Configurations are always copied from repo to prevent local drift
- **Complete toolchain**: Includes LazyGit for Git workflow, yq/jq for data processing
- **Dependency management**: Automatically installs required tools (yq, jq, lazygit)

### Testing Configuration
```bash
# Test configuration syntax
nvim --headless -c "quit"

# Check for errors
nvim -c "checkhealth"

# Test state management
./install_nvim.sh --show-state
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

The install script (`install_nvim.sh`) provides flexible installation with these key flags:
- `--skip-fonts` - Skip JetBrains Mono font installation
- `--skip-deps` - Skip dependency installations (ripgrep, fd, fzf)
- `--skip-node/python` - Skip language-specific installations
- `--skip-tmux` - Skip tmux installation and configuration (installed by default)
- `--skip-backup` - Skip backing up existing configuration

**Note**: Tmux configuration is now installed by default as it's essential for the Claude CLI workflow.

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