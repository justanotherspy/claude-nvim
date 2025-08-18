# 🚀 Daniel's Neovim Configuration

A feature-rich, performance-optimized Neovim setup tailored for modern development workflows with Claude CLI integration.

![Neovim](https://img.shields.io/badge/Neovim-0.10+-57A143?style=for-the-badge&logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/Lua-2C2D72?style=for-the-badge&logo=lua&logoColor=white)
![MIT License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

## ✨ Features

### 🎨 **Modern UI & Theme**
- **Monokai Pro** color scheme with rich syntax highlighting
- **JetBrains Mono** font with perfect programming ligatures
- Beautiful dashboard with quick access to files and projects
- Elegant status line and buffer tabs
- Smooth animations and transitions

### 🔧 **Development Tools**
- **LSP Support**: Full language server integration for 10+ languages
- **Autocompletion**: Intelligent code completion with snippets
- **Syntax Highlighting**: Advanced treesitter-based highlighting
- **Linting & Formatting**: Real-time code analysis and auto-formatting
- **Git Integration**: LazyGit, Gitsigns, and Fugitive for complete Git workflow
- **YAML/JSON Processing**: Built-in yq and jq tools for configuration management

### 🔍 **Fuzzy Finding & Search**
- **Telescope**: Advanced file and text searching with live preview
- **FZF-Lua**: Lightning-fast alternative fuzzy finder
- **Ripgrep Integration**: Blazing fast text search across projects
- **Smart File Navigation**: Exclude build dirs, respect .gitignore

### 📁 **File Management**
- **Neo-tree**: Modern file explorer with Git status
- **Buffer Management**: Easy switching and organization
- **Project Navigation**: Quick access to recent files and projects

### 💻 **Terminal & Workflow**
- **Integrated Terminal**: ToggleTerm with floating and split options
- **Tmux Integration**: Seamless navigation between Neovim and tmux panes
- **Claude CLI Optimized**: Perfect workflow for AI-assisted development

## 🛠 **Supported Languages**

### **Primary Stack**
| Language | LSP Server | Features |
|----------|------------|----------|
| **Go** | `gopls` | Formatting, linting, debugging |
| **Rust** | `rust_analyzer` | Cargo integration, Clippy |
| **TypeScript** | `ts_ls` | InlayHints, auto-imports |
| **Python** | `pyright` | Type checking, uv support |
| **Lua** | `lua_ls` | Neovim API integration |

### **Additional Support**
- **Markdown** - Documentation and notes
- **Bash** - Shell scripting
- **HTML/CSS** - Web development
- **JSON/YAML** - Configuration with schema validation
- **Docker** - Containerization
- **Terraform** - Infrastructure as code

## 🚀 **Quick Start**

### **Cross-Platform Support**
✅ **Linux** (Ubuntu, Debian, and derivatives with `apt`)  
✅ **macOS** (with Homebrew) - Intel and Apple Silicon (M1/M2/M3) support

The installation script automatically detects your operating system and uses the appropriate package manager:
- **Linux**: Uses `apt` for system packages
- **macOS**: Uses `brew` for package management, automatically installs Homebrew if needed

### **Installation**

#### **Quick Install**
```bash
# Clone this configuration
git clone <repo-url> ~/.config/nvim-config

# Run the installer (works on both Linux and macOS)
cd ~/.config/nvim-config
./install.sh

# Start Neovim
nvim
```

#### **Idempotent Installation**
The install script is **idempotent** and **cross-platform** - it can be run multiple times safely and will only install missing components. Installation state is tracked in `~/.config/claude-nvim/state.yaml`.

```bash
# Full installation with all features
./install.sh

# Check installation status
./install.sh --show-state

# Skip font installation
./install.sh --skip-fonts

# Full installation (includes tmux configuration)
./install.sh

# Reset state for fresh installation
./install.sh --reset-state

# Minimal installation (skip fonts and dependencies)
./install.sh --skip-fonts --skip-deps

# Skip specific components
./install.sh --skip-node --skip-python

# Install without tmux configuration
./install.sh --skip-tmux
```

**Available Flags:**
- `--skip-fonts` - Skip JetBrains Mono font installation
- `--skip-deps` - Skip all dependency installations (ripgrep, fd, fzf)
- `--skip-node` - Skip Node.js installation
- `--skip-python` - Skip Python3 installation
- `--skip-backup` - Skip backing up existing configuration
- `--skip-plugins` - Skip automatic plugin installation
- `--skip-tmux` - Skip tmux installation and configuration
- `--show-state` - Show current installation state and exit
- `--reset-state` - Reset all installation states (for testing)
- `-h, --help` - Show help message with all options

**Note**: Tmux configuration is now installed by default as a core component of the development workflow, but can be skipped with `--skip-tmux`.

#### **State Management**
The installer tracks component installation status in `~/.config/claude-nvim/state.yaml`:

```yaml
# Component states: notcheckedyet, installed, notinstalled
neovim_check: installed
git_install: installed
yq_install: installed
jq_install: installed
ripgrep_install: installed
fd_install: installed
fzf_install: installed
node_install: installed
python_install: installed
fonts_install: installed
config_backup: installed
config_install: installed
lazyvim_install: installed
plugins_install: installed
lazygit_install: installed
tmux_install: notinstalled
```

**State Management Benefits:**
- ✅ **Safe re-runs** - Won't duplicate installations
- ⚡ **Fast execution** - Skips already installed components
- 🔍 **Status visibility** - Easy to see what's installed
- 🧪 **Testing friendly** - Reset state for clean testing
- 🔄 **Config drift prevention** - Always updates configurations on each run
- 📦 **Complete toolchain** - Installs yq, jq, and lazygit automatically
- 🔄 **Cross-platform** - Works seamlessly on both Linux and macOS

#### **Mason LSP Server Setup**

If you encounter issues with LSP servers not installing automatically (especially on macOS ARM), use these approaches:

```bash
# Check current installation status (idempotent)
./setup-mason.sh

# Or manually install LSP servers in Neovim (recommended for first-time setup)
nvim -c ':Mason'

# Force reinstall all plugins and LSP servers
./install.sh --reset-state
```

**Mason Features:**
- ✅ **Automatic installation** - LSP servers installed during initial setup
- 🔧 **Manual fallback** - Dedicated script for troubleshooting
- 🍎 **macOS ARM support** - Enhanced compatibility for Apple Silicon
- 📦 **14 LSP servers** - Complete language support out of the box
- ⚡ **Parallel installation** - Fast, concurrent server downloads

**Supported LSP Servers:**
- `lua_ls` (Lua/Neovim), `rust_analyzer` (Rust), `ts_ls` (TypeScript/JS)
- `gopls` (Go), `pyright` (Python), `bashls` (Bash)
- `marksman` (Markdown), `jsonls` (JSON), `taplo` (TOML)
- `html` (HTML), `cssls` (CSS), `yamlls` (YAML)
- `dockerls` (Docker), `terraformls` (Terraform/HCL)

#### **Package Manager Details**

**Linux (apt):**
- System packages via `apt` (ripgrep, fd-find, jq, yq, etc.)
- Node.js via NodeSource repository
- Fonts installed to `/usr/share/fonts/`
- LazyGit via GitHub releases

**macOS (Homebrew):**
- All packages via `brew` (ripgrep, fd, jq, yq, node, etc.) 
- Fonts via `brew install --cask font-jetbrains-mono`
- LazyGit via `brew install lazygit` (fallback to GitHub releases with ARM64/x86_64 detection)
- Automatic Homebrew installation if not present
- Full support for Apple Silicon (M1/M2/M3) and Intel Macs

### **Essential Keybindings**

#### **Leader Key: `Space`**

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>ff` | Find Files | Fuzzy find files with Telescope |
| `<leader>fg` | Live Grep | Search text across project |
| `<leader>e` | File Explorer | Toggle Neo-tree |
| `<leader>tt` | Terminal | Toggle floating terminal |
| `<leader>lg` | LazyGit | Open Git interface |

#### **Development**
| Key | Action | Description |
|-----|--------|-------------|
| `gd` | Go to Definition | Jump to symbol definition |
| `K` | Hover | Show documentation |
| `<leader>ca` | Code Actions | Show available actions |
| `<leader>rn` | Rename | Rename symbol |
| `<leader>f` | Format | Format current file |

#### **Navigation**
| Key | Action | Description |
|-----|--------|-------------|
| `Shift+h` | Previous Buffer | Switch to previous buffer |
| `Shift+l` | Next Buffer | Switch to next buffer |
| `<leader>bd` | Delete Buffer | Close current buffer |
| `Ctrl+h/j/k/l` | Window Navigation | Move between splits |

## 📖 **Documentation**

- **[USAGE_GUIDE.md](./USAGE_GUIDE.md)** - Comprehensive usage guide
- **[TMUX_GUIDE.md](./TMUX_GUIDE.md)** - Complete tmux configuration and controls guide
- **[CLAUDE.md](./CLAUDE.md)** - Claude Code integration details
- **[install.sh](./install.sh)** - Automated installation script

## 🔧 **Architecture**

```
nvim/
├── init.lua                    # Main configuration entry point
├── lua/
│   ├── config/                 # Core Neovim settings
│   │   ├── options.lua        # Editor options
│   │   ├── keymaps.lua        # Key bindings
│   │   └── autocmds.lua       # Auto commands
│   └── plugins/               # Plugin configurations
│       ├── colorscheme.lua    # Monokai Pro theme
│       ├── lsp.lua           # Language server setup
│       ├── telescope.lua     # Fuzzy finder
│       ├── neo-tree.lua      # File explorer
│       ├── git.lua           # Git integration
│       ├── terminal.lua      # Terminal management
│       ├── fzf-lua.lua       # Alternative fuzzy finder
│       └── ui.lua            # UI enhancements
├── tmux.conf                  # Enhanced tmux configuration
├── USAGE_GUIDE.md             # Detailed usage instructions
├── TMUX_GUIDE.md              # Complete tmux controls guide
└── install.sh                # Installation script
```

## 🎯 **Optimized Workflows**

### **Claude CLI + Neovim + Tmux**
Perfect setup for AI-assisted development:

1. **Start tmux session**: `tmux new -s dev`
2. **Split for Neovim**: Open nvim in main pane
3. **Split for Claude**: Run `claude` in side pane
4. **Seamless navigation**: Use `Ctrl+h/j/k/l` to move between panes

#### **Essential Tmux Shortcuts**

**Session Management:**
- `tmux new -s <name>` - Create new session with name
- `tmux attach -t <name>` - Attach to existing session
- `tmux list-sessions` - List all sessions
- `Ctrl+a d` - Detach from session

**Pane Management:**
- `Ctrl+a |` - Split pane horizontally (side by side)
- `Ctrl+a -` - Split pane vertically (top/bottom)
- `Ctrl+a h/j/k/l` - Navigate between panes (vim-style)
- `Alt+Arrow Keys` - Navigate between panes (arrow keys)
- `Ctrl+a H/J/K/L` - Resize panes (hold and repeat)
- `Ctrl+a x` - Close current pane

**Window Management:**
- `Ctrl+a c` - Create new window
- `Ctrl+a n` - Next window
- `Ctrl+a p` - Previous window
- `Ctrl+a <number>` - Switch to window number
- `Ctrl+Shift+Left/Right` - Quick window switching

**Configuration:**
- `Ctrl+a r` - Reload tmux configuration
- Mouse support enabled - click to select panes and resize
- Copy mode uses vim keys (`Ctrl+a [` to enter, `v` to select, `y` to copy)

### **Git Workflow**
Streamlined version control:

1. **Stage changes**: `<leader>hs` (stage hunk)
2. **Review changes**: `<leader>lg` (LazyGit interface)
3. **Commit & push**: All within LazyGit
4. **Diff viewing**: `<leader>gd` for quick diffs

### **Project Development**
Efficient coding workflow:

1. **Find files**: `<leader>ff` for quick file access
2. **Search code**: `<leader>fg` for project-wide search
3. **Navigate code**: `gd`, `gr` for definitions and references
4. **Terminal tasks**: `<leader>tt` for running commands

## 🛡️ **Requirements**

- **Neovim 0.10+**
- **Git 2.0+**
- **Node.js 18+** (for LSP servers)
- **Python 3.8+** (for Python development)
- **Go 1.19+** (for Go development)
- **Rust 1.70+** (for Rust development)

### **Optional Dependencies**
- **ripgrep** - Fast text search
- **fd** - Fast file finding
- **fzf** - Fuzzy finder
- **lazygit** - Git interface
- **JetBrains Mono Font** - Programming font

## 🤝 **Contributing**

This is a personal configuration, but feel free to:
- Fork and customize for your needs
- Report issues or suggest improvements
- Share your own configurations inspired by this setup

## 📄 **License**

MIT License - Feel free to use and modify as needed.

---

**Built with ❤️ for modern development workflows**

*Optimized for Go, Rust, TypeScript, Python development with Claude CLI integration*