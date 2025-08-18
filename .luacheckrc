-- Luacheck configuration for Neovim
-- See: https://luacheck.readthedocs.io/en/stable/config.html

-- Global settings
std = "luajit"
cache = true

-- Global variables that are OK to use and modify
globals = {
    "vim", -- Neovim's vim global (allow full access)
    "_LAZYGIT_TOGGLE", -- Terminal toggles
    "_NODE_TOGGLE",
    "_PYTHON_TOGGLE", 
    "_BTOP_TOGGLE",
    "OpenUrlUnderCursor", -- URL handler function
}

-- Files and directories to ignore
exclude_files = {
    ".luarocks",
    ".install",
    "*.rockspec",
}

-- Ignore specific warnings
ignore = {
    "111", -- Setting non-standard global variable (for our terminal toggles)
    "122", -- Setting read-only field (vim.opt, vim.g, etc. are meant to be set)
    "212", -- Unused argument (common in Neovim callbacks)
    "213", -- Unused loop variable
    "211", -- Unused variable (sometimes variables are defined for clarity)
    "611", -- Line contains only whitespace (formatting preference)
    "612", -- Line contains trailing whitespace (formatter handles this)
    "631", -- Line is too long (formatter handles this)
}

-- Set max line length (generous for config files)
max_line_length = 120

-- Allow unused self parameter (common in OOP Lua)
self = false

-- Neovim specific settings
files["**/*"] = {
    -- Allow vim global modifications in all files
    globals = {"vim"}
}