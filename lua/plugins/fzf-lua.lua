-- FZF-Lua: Pure Lua implementation of fzf for fast fuzzy finding

return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "FzfLua",
  keys = {
    -- Alternative fuzzy finder mappings (using Alt modifier to avoid conflicts)
    { "<A-f>", "<cmd>FzfLua files<cr>", desc = "FzfLua files" },
    { "<A-g>", "<cmd>FzfLua live_grep<cr>", desc = "FzfLua live grep" },
    { "<A-b>", "<cmd>FzfLua buffers<cr>", desc = "FzfLua buffers" },
    { "<A-h>", "<cmd>FzfLua help_tags<cr>", desc = "FzfLua help" },
    { "<A-c>", "<cmd>FzfLua commands<cr>", desc = "FzfLua commands" },
    { "<A-r>", "<cmd>FzfLua oldfiles<cr>", desc = "FzfLua recent files" },
    { "<A-s>", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "FzfLua symbols" },
    { "<A-d>", "<cmd>FzfLua lsp_definitions<cr>", desc = "FzfLua definitions" },
    { "<A-x>", "<cmd>FzfLua quickfix<cr>", desc = "FzfLua quickfix" },
  },
  config = function()
    require("fzf-lua").setup({
      "max-perf", -- Performance optimized profile
      winopts = {
        height = 0.85,
        width = 0.80,
        preview = {
          default = "bat",
          border = "rounded",
          vertical = "down:45%",
          horizontal = "right:50%",
        },
      },
      files = {
        cmd = "rg --files --hidden --follow --no-ignore-vcs",
        git_icons = true,
        file_icons = true,
        color_icons = true,
      },
      grep = {
        cmd = "rg --line-number --no-heading --color=always --smart-case --hidden --follow",
        git_icons = true,
        file_icons = true,
        color_icons = true,
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden --follow"
               .. " --glob '!**/.git/*'"
               .. " --glob '!**/node_modules/*'"
               .. " --glob '!**/target/*'"
               .. " --glob '!**/.next/*'"
               .. " --glob '!**/dist/*'"
               .. " --glob '!**/.cache/*'",
      },
      buffers = {
        sort_lastused = true,
        sort_mru = true,
      },
      oldfiles = {
        cwd_only = false,
        stat_file = true,
      },
      quickfix = {
        file_icons = true,
        git_icons = true,
      },
      lsp = {
        code_actions = {
          previewer = "codeaction_native",
          preview_pager = "delta --side-by-side --width=$FZF_PREVIEW_COLUMNS --hunk-header-style=omit",
        },
      },
      -- Use fzf binary for maximum performance
      fzf_bin = "fzf",
      fzf_opts = {
        ["--ansi"] = "",
        ["--info"] = "inline",
        ["--height"] = "100%",
        ["--layout"] = "reverse",
        ["--border"] = "none",
        ["--highlight-line"] = "",
      },
    })
  end,
}