# Tmux Complete Guide

## Quick Start

### Installation
```bash
# Linux
sudo apt-get install tmux

# macOS
brew install tmux

# Apply configuration
cp tmux.conf ~/.tmux.conf
tmux source-file ~/.tmux.conf
```

### Basic Commands (from terminal)
```bash
tmux                        # Start new session
tmux new -s work           # Start named session
tmux ls                    # List sessions
tmux attach                # Attach to last session
tmux attach -t work        # Attach to named session
tmux kill-session -t work  # Kill named session
```

## Key Bindings Reference

> **Note**: Prefix key is `Ctrl+a` (not the default `Ctrl+b`)

### Session Management

| Key Binding | Action |
|------------|--------|
| `Prefix + S` | List and switch sessions |
| `Prefix + N` | Create new session |
| `Prefix + $` | Rename current session |
| `Prefix + d` | Detach from session |
| `Prefix + D` | Choose session to detach |

### Window Management

| Key Binding | Action |
|------------|--------|
| `Prefix + c` | Create new window (in current path) |
| `Prefix + ,` | Rename current window |
| `Prefix + w` | List all windows |
| `Prefix + &` | Kill current window (with confirmation) |
| `Prefix + 0-9` | Switch to window by number |
| `Ctrl+Shift+Left` | Previous window (no prefix needed) |
| `Ctrl+Shift+Right` | Next window (no prefix needed) |
| `Prefix + Tab` | Jump to last active window |
| `Prefix + Shift+Left` | Move window left |
| `Prefix + Shift+Right` | Move window right |

### Pane Management

#### Creating Panes
| Key Binding | Action |
|------------|--------|
| `Prefix + \|` | Split horizontally (creates vertical divider) |
| `Prefix + -` | Split vertically (creates horizontal divider) |
| `Prefix + E` | Even horizontal split (2 equal panes) |
| `Prefix + V` | Even vertical split (2 equal panes) |
| `Prefix + C` | Create 3-pane dev layout (editor\|terminal\|claude) |

#### Navigating Panes
| Key Binding | Action |
|------------|--------|
| `Prefix + h/j/k/l` | Navigate panes (vim-style) |
| `Alt + Arrow Keys` | Navigate panes (no prefix needed) |
| `Ctrl + h/j/k/l` | Smart navigation (tmux/vim aware) |
| `Prefix + ;` | Go to last active pane |
| `Prefix + o` | Go to next pane (cycle) |
| `Prefix + q` | Show pane numbers (type number to jump) |

#### Managing Panes
| Key Binding | Action |
|------------|--------|
| `Prefix + x` | Kill current pane (with confirmation) |
| `Prefix + z` | Toggle pane zoom (fullscreen) |
| `Prefix + Space` | Toggle between layouts |
| `Prefix + !` | Break pane into new window |
| `Prefix + {` | Move pane left |
| `Prefix + }` | Move pane right |
| `Prefix + >` | Swap with next pane |
| `Prefix + <` | Swap with previous pane |

#### Resizing Panes
| Key Binding | Action |
|------------|--------|
| `Prefix + H/J/K/L` | Resize by 5 units (hold to repeat) |
| `Prefix + </>` | Fine resize by 1 unit (hold to repeat) |

### Copy Mode

| Key Binding | Action |
|------------|--------|
| `Prefix + [` | Enter copy mode |
| `Prefix + ]` | Paste from buffer |
| `Prefix + =` | Choose buffer to paste |

#### Inside Copy Mode (vim-style)
| Key | Action |
|-----|--------|
| `h/j/k/l` | Navigate |
| `w/b` | Jump words forward/backward |
| `f/F` | Find character forward/backward |
| `g/G` | Go to top/bottom |
| `0/$` | Go to line start/end |
| `v` | Start character selection |
| `V` | Start line selection |
| `Ctrl+v` | Start block selection |
| `y` | Copy selection to clipboard |
| `Enter` | Copy selection (alternative) |
| `q` | Exit copy mode |
| `/` | Search forward |
| `?` | Search backward |
| `n/N` | Next/previous search result |

### Special Features

| Key Binding | Action |
|------------|--------|
| `Prefix + r` | Reload tmux configuration |
| `Prefix + P` | Toggle pane synchronization (type in all panes) |
| `Prefix + m` | Toggle mouse mode on/off |
| `Prefix + b` | Toggle status bar visibility |
| `Prefix + t` | Show time |
| `F12` | Toggle key bindings (for nested tmux) |
| `Ctrl+l` | Clear screen and scrollback |

## Claude CLI Workflow

### Optimal Setup
1. Start tmux session: `tmux new -s dev`
2. Create 3-pane layout: `Prefix + C`
   - Left pane: Neovim for editing
   - Top-right: Terminal for commands
   - Bottom-right: Claude CLI

### Workflow Tips
```bash
# In pane 1 (editor)
nvim file.py

# In pane 2 (terminal)
python file.py

# In pane 3 (Claude)
claude "Help me optimize this function"
```

### Quick Pane Switching
- `Alt + Arrows` - Jump between panes without prefix
- `Prefix + ;` - Toggle between last two panes
- `Prefix + z` - Zoom current pane for focus

## Advanced Features

### Pane Synchronization
Useful for running same command across multiple servers:
1. Split into multiple panes
2. `Prefix + P` to enable sync
3. Type commands (appears in all panes)
4. `Prefix + P` to disable sync

### Mouse Mode
When enabled (`Prefix + m`):
- Click to select pane
- Drag borders to resize
- Scroll with mouse wheel
- Select text to copy

### Nested Tmux Sessions
Working on remote server with tmux:
1. `F12` - Disable local tmux keys
2. Work in remote tmux normally
3. `F12` - Re-enable local tmux keys

### Session Persistence (with plugins)
```bash
# Install TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Add to ~/.tmux.conf
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# Install plugins: Prefix + I
# Save session: Prefix + Ctrl+s
# Restore session: Prefix + Ctrl+r
```

## Clipboard Integration

### Linux
```bash
# Install xclip for clipboard support
sudo apt-get install xclip

# Copy mode will now use system clipboard
```

### macOS
```bash
# Works out of the box with pbcopy/pbpaste
```

### Copy/Paste Workflow
1. `Prefix + [` - Enter copy mode
2. Navigate to text start
3. `v` - Start selection
4. Navigate to text end
5. `y` - Copy to system clipboard
6. `Prefix + ]` - Paste

## Status Bar Indicators

### Left Side
- Session name (orange background)
- Current window and pane numbers

### Center
- Window list with highlighting for:
  - Current window (orange)
  - Other windows (gray)
  - Activity indicator (`*`)
  - Last window (`-`)

### Right Side
- Time (HH:MM format)
- Date (day-month-year)
- Hostname

## Troubleshooting

### Common Issues

**Colors look wrong**
```bash
# Add to shell config (.bashrc/.zshrc)
export TERM=screen-256color
```

**Can't copy to clipboard**
```bash
# Linux: Install xclip
sudo apt-get install xclip

# macOS: Should work automatically
```

**Escape key delay in vim**
```bash
# Already fixed in config with:
set -sg escape-time 0
```

**Mouse scroll not working**
```bash
# Toggle mouse mode
Prefix + m
```

**Prefix key conflicts**
```bash
# Change in ~/.tmux.conf if needed
set-option -g prefix C-Space  # Example: Ctrl+Space
```

## Customization Tips

### Change Color Scheme
Edit these lines in `~/.tmux.conf`:
```bash
# Status bar colors
set -g status-style bg=colour235,fg=colour136

# Active pane border
set -g pane-active-border-style fg=colour166
```

### Add Custom Bindings
```bash
# Example: Quick split and resize
bind % split-window -h -p 30  # 30% width split
```

### Integrate with Shell
Add to `.bashrc` or `.zshrc`:
```bash
# Auto-attach to tmux
if [ -z "$TMUX" ]; then
    tmux attach || tmux new -s main
fi
```

## Quick Command Reference Card

```
┌─────────────────────────────────────────────────────┐
│                  TMUX QUICK REFERENCE                │
├─────────────────────────────────────────────────────┤
│ Prefix: Ctrl+a                                       │
├─────────────────────────────────────────────────────┤
│ SESSIONS            │ WINDOWS                        │
│ S  - list          │ c     - create                 │
│ N  - new           │ ,     - rename                 │
│ $  - rename        │ w     - list                   │
│ d  - detach        │ &     - kill                   │
├────────────────────┼────────────────────────────────┤
│ PANES              │ COPY MODE                      │
│ |  - split h       │ [     - enter                  │
│ -  - split v       │ ]     - paste                  │
│ x  - kill          │ v     - select                 │
│ z  - zoom          │ y     - copy                   │
│ C  - dev layout    │ q     - quit                   │
├────────────────────┼────────────────────────────────┤
│ NAVIGATE           │ RESIZE                         │
│ h/j/k/l - vim      │ H/J/K/L - by 5                │
│ Alt+Arrow - quick  │ </>     - by 1                │
├────────────────────┴────────────────────────────────┤
│ SPECIAL: F12 (nested) | P (sync) | m (mouse)        │
└─────────────────────────────────────────────────────┘
```

## Best Practices

1. **Name your sessions**: `tmux new -s project-name`
2. **Use pane zoom**: Focus on one pane with `Prefix + z`
3. **Learn copy mode**: Much faster than mouse selection
4. **Create layouts**: Save common pane arrangements
5. **Use synchronize**: Great for cluster management
6. **Persistent paths**: New panes/windows inherit current directory
7. **Status bar info**: Customize to show what you need

## Integration with Neovim

The configuration includes smart pane switching that works seamlessly between tmux and Neovim:
- `Ctrl+h/j/k/l` navigates both tmux panes and Neovim splits
- Requires `christoomey/vim-tmux-navigator` plugin in Neovim

## Further Resources

- [Tmux Manual](https://man7.org/linux/man-pages/man1/tmux.1.html)
- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)
- [TPM Plugins](https://github.com/tmux-plugins/list)