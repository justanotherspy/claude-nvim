# Neovim Error Logging System

This Neovim configuration includes a comprehensive error logging system that captures all errors, warnings, and LSP issues to help diagnose intermittent problems.

## Log Location

Error logs are stored in: `~/.local/state/nvim/nvim-errors/error.log`

## Features

- **Automatic Error Capture**: All errors and warnings are automatically logged
- **LSP Error Tracking**: Specific tracking for LSP server initialization and attachment issues
- **Log Rotation**: Automatic rotation when log exceeds 10MB (keeps 5 backup files)
- **Diagnostic Logging**: Captures diagnostic errors from language servers
- **Timestamped Entries**: All log entries include timestamps for tracking

## Using the Error Logger

### Within Neovim

The error logger provides several commands:

```vim
:ShowErrors [n]      " Show last n lines of error log (default: 50)
:ClearErrorLog       " Clear the error log
:ErrorLogPath        " Display the path to the error log file
```

### From the Command Line

Use the provided script to view errors:

```bash
# View last 50 errors
./view-nvim-errors.sh

# View last 100 errors
./view-nvim-errors.sh -n 100

# Follow the log in real-time
./view-nvim-errors.sh -f

# Show only ERROR level messages
./view-nvim-errors.sh -e

# Show only LSP-related messages
./view-nvim-errors.sh -l

# Clear the error log
./view-nvim-errors.sh -c
```

## Log Format

Each log entry follows this format:
```
[YYYY-MM-DD HH:MM:SS] [LEVEL] (Source) Message
```

Example:
```
[2024-08-19 09:15:30] [ERROR] (LSP) Failed to setup LSP server: tsserver
[2024-08-19 09:15:31] [WARN] (General) Plugin not found: some-plugin
[2024-08-19 09:15:32] [INFO] (LSP) LSP attached: lua_ls
```

## Levels

- **ERROR**: Critical errors that prevent functionality
- **WARN**: Warnings that may affect functionality
- **INFO**: Informational messages (LSP attachments, successful operations)

## Troubleshooting Workflow

1. **Experience an error in Neovim**: Continue working normally
2. **Check the log later**: Run `:ShowErrors` or use the script
3. **Identify patterns**: Look for repeated errors or specific LSP failures
4. **Share logs for debugging**: The log file can be shared to help diagnose issues

## Manual Testing

To manually test error logging:

```lua
-- In Neovim command mode
:lua vim.notify("Test error", vim.log.levels.ERROR)
:lua vim.notify("Test warning", vim.log.levels.WARN)
```

## Implementation Details

The error logger:
- Overrides `vim.notify()` to capture all notifications
- Hooks into LSP handlers for server-specific errors
- Monitors diagnostic changes for language server errors
- Captures buffer read errors and plugin loading issues

## Disabling Error Logging

If you need to disable error logging temporarily, comment out this line in `~/.config/nvim/init.lua`:

```lua
-- require("config.error-logger").setup()
```

## Log File Management

The system automatically:
- Rotates logs when they exceed 10MB
- Keeps up to 5 backup files (error.log.1, error.log.2, etc.)
- Creates the log directory if it doesn't exist

## Known Limitations

- Some very early startup errors may not be captured
- Binary data or very long messages may be truncated
- Performance impact is minimal but measurable on very slow systems