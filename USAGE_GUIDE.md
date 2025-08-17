# Neovim Configuration Usage Guide

## Table of Contents
1. [Getting Started](#getting-started)
2. [Key Concepts](#key-concepts)
3. [Essential Commands](#essential-commands)
4. [File Management](#file-management)
5. [Buffer Management](#buffer-management)
6. [Window Management](#window-management)
7. [Terminal Usage](#terminal-usage)
8. [Git Integration](#git-integration)
9. [LSP Features](#lsp-features)
10. [Search and Navigation](#search-and-navigation)
11. [Tmux Integration](#tmux-integration)
12. [Workflow with Claude CLI](#workflow-with-claude-cli)

## Getting Started

### Installation

1. Copy this configuration to your Neovim config directory:
```bash
cp -r /home/daniel/claude/nvim/* ~/.config/nvim/
```

2. Install JetBrains Mono font:
```bash
# Ubuntu/Pop!_OS
sudo apt install fonts-jetbrains-mono

# Or download from: https://www.jetbrains.com/lp/mono/
```

3. Open Neovim and let Lazy.nvim install plugins:
```bash
nvim
# Plugins will auto-install on first launch
```

### Leader Key
The **Leader key** is set to **Space** (`<Space>`). Most custom commands start with pressing Space followed by other keys.

## Key Concepts

### Modes in Vim/Neovim
- **Normal Mode** (default): For navigation and commands
- **Insert Mode** (`i`, `a`, `o`): For typing text
- **Visual Mode** (`v`, `V`, `Ctrl-v`): For selecting text
- **Command Mode** (`:`): For executing commands
- **Terminal Mode** (`<leader>tt`): For terminal interaction

### Escaping to Normal Mode
- Press `Esc` or
- Press `jk` or `kj` (custom mapping for faster escape)

## Essential Commands

### Basic Navigation
- `h`, `j`, `k`, `l` - Move left, down, up, right
- `w` - Jump to next word
- `b` - Jump to previous word
- `0` - Jump to beginning of line
- `$` - Jump to end of line
- `gg` - Jump to beginning of file
- `G` - Jump to end of file
- `Ctrl-d` - Scroll down half page
- `Ctrl-u` - Scroll up half page

### Basic Editing
- `i` - Insert before cursor
- `a` - Insert after cursor
- `o` - Insert new line below
- `O` - Insert new line above
- `dd` - Delete line
- `yy` - Copy line
- `p` - Paste after cursor
- `P` - Paste before cursor
- `u` - Undo
- `Ctrl-r` - Redo

### Saving and Quitting
- `:w` - Save file
- `:w filename` - Save as new file
- `:q` - Quit
- `:wq` or `:x` - Save and quit
- `:q!` - Quit without saving
- `<leader>q` - Quick quit
- `<leader>Q` - Force quit all
- `Ctrl-s` - Quick save (works in Normal and Insert mode)

## File Management

### File Explorer (Neo-tree)
- `<leader>e` - Toggle file explorer
- `<leader>E` - Focus file explorer

#### Neo-tree Navigation
- `j`/`k` - Move up/down
- `Enter` - Open file/folder
- `h`/`l` - Close/open folder
- `a` - Add new file
- `A` - Add new directory
- `d` - Delete file/folder
- `r` - Rename
- `y` - Copy
- `x` - Cut
- `p` - Paste
- `R` - Refresh tree
- `?` - Show help

### Finding Files (Telescope)
- `<leader>ff` - Find files
- `<leader>fg` - Live grep (search in files)
- `<leader>fw` - Search word under cursor
- `<leader>fo` - Recent files
- `<leader>fh` - Help tags
- `<leader>fc` - Commands
- `<leader>fk` - Keymaps

### Creating New Files
1. **From Neo-tree**: Press `a` in the file explorer
2. **From command**: `:e filename`
3. **From Telescope**: `<leader>ff` then type new filename
4. **From terminal**: `<leader>tt` then use `touch` or `nvim filename`

## Buffer Management

### What are Buffers?
Buffers are in-memory representations of files. You can have multiple buffers open and switch between them.

### Buffer Commands
- `<leader>fb` - Find buffers (Telescope)
- `<leader>be` - Buffer explorer (Neo-tree)
- `<Shift-h>` - Previous buffer
- `<Shift-l>` - Next buffer
- `<leader>bd` - Delete current buffer
- `<leader>ba` - Close all buffers except current
- `:ls` or `:buffers` - List all buffers
- `:b <number>` - Go to buffer number
- `:b <partial_name>` - Go to buffer by name

## Window Management

### Splitting Windows
- `<leader>sv` - Split vertically
- `<leader>sh` - Split horizontally
- `<leader>se` - Make splits equal size
- `<leader>sx` - Close current split

### Navigating Windows
- `Ctrl-h` - Move to left window
- `Ctrl-j` - Move to down window
- `Ctrl-k` - Move to up window
- `Ctrl-l` - Move to right window

### Resizing Windows
- `Ctrl-Up` - Decrease height
- `Ctrl-Down` - Increase height
- `Ctrl-Left` - Decrease width
- `Ctrl-Right` - Increase width

### Tabs
- `<leader>to` - Open new tab
- `<leader>tx` - Close tab
- `<leader>tn` - Next tab
- `<leader>tp` - Previous tab

## Terminal Usage

### Opening Terminal
- `<leader>tt` - Toggle terminal
- `<leader>tf` - Floating terminal
- `<leader>th` - Horizontal terminal
- `<leader>tv` - Vertical terminal
- `Ctrl-\` - Toggle terminal (global)

### Special Terminals
- `<leader>tg` - LazyGit terminal
- `<leader>tn` - Node REPL
- `<leader>tp` - Python REPL
- `<leader>tb` - Btop system monitor

### Terminal Navigation
- `Esc` or `jk` - Exit terminal mode to Normal mode
- `Ctrl-h/j/k/l` - Navigate between terminal and other windows
- `i` - Enter terminal mode (when in Normal mode)

## Git Integration

### Git Commands (Fugitive)
- `<leader>gg` - Git status
- `<leader>gC` - Git commit
- `<leader>gP` - Git push
- `<leader>gp` - Git pull
- `<leader>gB` - Git blame
- `<leader>gd` - Git diff
- `<leader>gl` - Git log (oneline)
- `<leader>gL` - Git log (full)

### Git Hunks (Gitsigns)
- `]c` - Next hunk
- `[c` - Previous hunk
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hS` - Stage buffer
- `<leader>hR` - Reset buffer
- `<leader>hp` - Preview hunk
- `<leader>hb` - Blame line
- `<leader>tb` - Toggle line blame
- `<leader>td` - Toggle deleted lines

### LazyGit
- `<leader>lg` - Open LazyGit
- `<leader>lf` - LazyGit for current file

### Git Search (Telescope)
- `<leader>gc` - Search git commits
- `<leader>gb` - Search git branches
- `<leader>gs` - Git status
- `<leader>gS` - Git stash

## LSP Features

### Code Navigation
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `go` - Go to type definition
- `gr` - Find references
- `K` - Hover documentation
- `gs` - Signature help

### Code Actions
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `<leader>f` - Format file
- `gl` - Show diagnostics
- `[d` - Previous diagnostic
- `]d` - Next diagnostic

### LSP Search (Telescope)
- `<leader>lr` - Find references
- `<leader>ld` - Find definitions
- `<leader>li` - Find implementations
- `<leader>lt` - Find type definitions
- `<leader>ls` - Document symbols
- `<leader>lS` - Workspace symbols
- `<leader>le` - Diagnostics

### LSP Saga
- `<leader>lf` - LSP Finder
- `<leader>la` - Code Action
- `<leader>lp` - Peek Definition
- `<leader>lo` - Outline
- `<leader>lh` - Hover Doc

## Search and Navigation

### Text Search
- `/pattern` - Search forward
- `?pattern` - Search backward
- `n` - Next match
- `N` - Previous match
- `<leader>h` - Clear search highlighting
- `*` - Search word under cursor forward
- `#` - Search word under cursor backward

### Quick Navigation
- `<leader>s` - Replace word under cursor globally
- `Ctrl-a` - Select all

## Tmux Integration

### Why Use Tmux with Neovim?
Tmux allows you to:
- Create persistent sessions
- Split terminal into panes
- Switch between multiple projects
- Keep processes running in background

### Basic Tmux Commands
```bash
# Start new session
tmux new -s myproject

# Attach to session
tmux attach -t myproject

# List sessions
tmux ls

# Detach from session
Ctrl-b d
```

### Tmux + Neovim Navigation
- `Ctrl-h/j/k/l` - Seamlessly navigate between Tmux panes and Neovim windows

## Workflow with Claude CLI

### Optimal Setup
1. **Use Tmux** for session management:
```bash
# Create a development session
tmux new -s dev

# Split horizontally for Claude CLI
Ctrl-b %

# In left pane: Neovim
nvim

# In right pane: Claude CLI
claude
```

2. **Project Structure**:
```bash
project/
├── .claude/
│   └── CLAUDE.md  # Project-specific Claude instructions
├── src/           # Source code
└── README.md      # Documentation
```

3. **Workflow Tips**:
- Use `<leader>tt` to quickly open terminal for running commands
- Use `<leader>lg` for git operations
- Use `<leader>ff` to quickly find files
- Use `<leader>fg` to search across project
- Keep Claude CLI in adjacent Tmux pane for AI assistance

### Example Development Flow

1. **Start Session**:
```bash
tmux new -s myproject
cd ~/projects/myproject
nvim
```

2. **Open Terminal for Testing**:
- Press `<leader>tt` for floating terminal
- Run tests, builds, etc.
- Press `Esc` to close

3. **Git Workflow**:
- Make changes in Neovim
- Press `<leader>lg` for LazyGit
- Stage, commit, push
- Press `q` to exit LazyGit

4. **AI Assistance**:
- Split Tmux: `Ctrl-b %`
- Run `claude` in new pane
- Ask questions, generate code
- Copy/paste between panes

## Tips and Tricks

### Productivity Boosters
1. **Which-key**: Press `<leader>` and wait to see available commands
2. **Fuzzy Finding**: Use `<leader>ff` frequently instead of navigating directories
3. **Multiple Cursors**: Use `Ctrl-v` for visual block mode
4. **Quick Escape**: Use `jk` or `kj` instead of reaching for Esc
5. **Smart Navigation**: Use `Ctrl-d/u` with centering for smooth scrolling

### Common Patterns
- **Edit Multiple Lines**: `Ctrl-v`, select lines, `I`, type, `Esc`
- **Global Replace**: `:%s/old/new/g`
- **Delete Inside**: `di"` (delete inside quotes), `di{` (delete inside braces)
- **Change Inside**: `ci"` (change inside quotes), `ciw` (change word)
- **Visual Selection**: `vi{` (select inside braces), `va{` (select including braces)

### Performance Tips
1. Lazy loading is configured - plugins load on demand
2. Use `<leader>ff` instead of Neo-tree for quick file access
3. LSP loads per filetype automatically
4. Terminal sessions persist in background

## Troubleshooting

### Common Issues

1. **Plugins not installing**:
```bash
nvim
:Lazy sync
```

2. **LSP not working**:
```bash
nvim
:Mason
# Install required language servers
```

3. **Font not displaying correctly**:
- Ensure JetBrains Mono is installed
- Configure terminal (Alacritty) to use JetBrains Mono

4. **Keybinding conflicts**:
```bash
:checkhealth
```

### Getting Help
- `:help <topic>` - Neovim help
- `<leader>fh` - Search help tags
- `:checkhealth` - Check configuration health
- `:Lazy` - Plugin manager interface
- `:Mason` - LSP installer interface

## Quick Reference Card

### Most Used Commands
| Command | Description |
|---------|------------|
| `<leader>ff` | Find files |
| `<leader>fg` | Search in files |
| `<leader>e` | File explorer |
| `<leader>tt` | Terminal |
| `<leader>lg` | LazyGit |
| `K` | Hover docs |
| `gd` | Go to definition |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename |
| `<Shift-h/l>` | Switch buffers |

Remember: Press `<leader>` (Space) and wait to see available options with Which-key!