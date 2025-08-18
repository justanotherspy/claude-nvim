-- Neovim Options Configuration

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs and indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = true
opt.linebreak = true
opt.breakindent = true

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

-- Cursor line
opt.cursorline = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cmdheight = 1
opt.scrolloff = 10
opt.sidescrolloff = 10
opt.completeopt = "menuone,noselect"
opt.conceallevel = 0
opt.pumheight = 10
opt.showmode = false
opt.showtabline = 2
opt.laststatus = 3

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Persistent undo
opt.undofile = true
opt.undolevels = 10000

-- Backup
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Update time
opt.updatetime = 50
opt.timeout = true
opt.timeoutlen = 300

-- Font (for GUI)
opt.guifont = "JetBrains Mono:h11"

-- Enable mouse
opt.mouse = "a"

-- Encoding
opt.fileencoding = "utf-8"

-- Fold
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false
opt.foldlevel = 99

-- Use ripgrep for grep
opt.grepprg = "rg --vimgrep --hidden --follow --smart-case"
opt.grepformat = "%f:%l:%c:%m"
