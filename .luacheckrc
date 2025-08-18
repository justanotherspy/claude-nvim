-- Luacheck configuration for Neovim
-- See: https://luacheck.readthedocs.io/en/stable/config.html

-- Global settings
std = "luajit"
cache = true

-- Global variables that are OK to use
globals = {
    "vim", -- Neovim's vim global
}

-- Read-only globals (can use but not modify)
read_globals = {
    "vim",
}

-- Files and directories to ignore
exclude_files = {
    ".luarocks",
    ".install",
}

-- Ignore specific warnings
ignore = {
    "212", -- Unused argument (common in Neovim callbacks)
    "213", -- Unused loop variable
    "631", -- Line is too long (we'll let formatter handle this)
}

-- Set max line length
max_line_length = 120

-- Allow unused self parameter (common in OOP Lua)
self = false