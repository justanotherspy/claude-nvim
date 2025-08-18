-- Neovim Configuration
-- Author: Daniel
-- Description: Feature-rich Neovim setup with Monokai theme, LSP, Git integration, and more

-- Disable unused providers FIRST (before any other setup)
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader key early
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core settings
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Load and configure plugins
require("lazy").setup("plugins", {
  install = {
    colorscheme = { "monokai-pro" },
    missing = true,  -- Install missing plugins on startup
  },
  checker = {
    enabled = true,
    notify = false,
    frequency = 3600, -- Check for updates every hour
  },
  change_detection = {
    notify = false,
    enabled = true,
  },
  performance = {
    rtp = {
      -- Disable some rtp plugins we don't need
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = "rounded",
    backdrop = 60,
  },
  rocks = {
    enabled = false,
  },
  defaults = {
    lazy = false,  -- Don't lazy load by default to ensure everything loads
  },
})
