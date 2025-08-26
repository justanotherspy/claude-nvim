#!/bin/bash

# Script to view Neovim error logs

ERROR_LOG="$HOME/.local/state/nvim/nvim-errors/error.log"

if [ ! -f "$ERROR_LOG" ]; then
    echo "No error log found at $ERROR_LOG"
    exit 1
fi

# Parse command line arguments
LINES=50
FILTER=""
FOLLOW=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--lines)
            LINES="$2"
            shift 2
            ;;
        -f|--follow)
            FOLLOW=true
            shift
            ;;
        -e|--errors-only)
            FILTER="ERROR"
            shift
            ;;
        -l|--lsp-only)
            FILTER="LSP"
            shift
            ;;
        -c|--clear)
            echo "Clearing error log..."
            > "$ERROR_LOG"
            echo "Error log cleared."
            exit 0
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -n, --lines N      Show last N lines (default: 50)"
            echo "  -f, --follow       Follow log file (like tail -f)"
            echo "  -e, --errors-only  Show only ERROR level messages"
            echo "  -l, --lsp-only     Show only LSP-related messages"
            echo "  -c, --clear        Clear the error log"
            echo "  -h, --help         Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "=== Neovim Error Log ==="
echo "Log file: $ERROR_LOG"
echo "File size: $(du -h "$ERROR_LOG" | cut -f1)"
echo "========================"
echo

if [ "$FOLLOW" = true ]; then
    if [ -n "$FILTER" ]; then
        tail -f "$ERROR_LOG" | grep "$FILTER"
    else
        tail -f "$ERROR_LOG"
    fi
else
    if [ -n "$FILTER" ]; then
        tail -n "$LINES" "$ERROR_LOG" | grep "$FILTER"
    else
        tail -n "$LINES" "$ERROR_LOG"
    fi
fi