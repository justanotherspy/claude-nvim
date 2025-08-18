-- Terminal Integration Configuration

return {
  -- Toggleterm for terminal management
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Floating terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Vertical terminal" },
      { "<leader>tg", "<cmd>lua _LAZYGIT_TOGGLE()<cr>", desc = "LazyGit terminal" },
      { "<leader>tn", "<cmd>lua _NODE_TOGGLE()<cr>", desc = "Node terminal" },
      { "<leader>tp", "<cmd>lua _PYTHON_TOGGLE()<cr>", desc = "Python terminal" },
      { "<leader>tb", "<cmd>lua _BTOP_TOGGLE()<cr>", desc = "Btop terminal" },
      -- Terminal mode mappings
      { "<esc>", [[<C-\><C-n>]], mode = "t", desc = "Exit terminal mode" },
      { "jk", [[<C-\><C-n>]], mode = "t", desc = "Exit terminal mode" },
      { "<C-h>", [[<Cmd>wincmd h<CR>]], mode = "t", desc = "Navigate left" },
      { "<C-j>", [[<Cmd>wincmd j<CR>]], mode = "t", desc = "Navigate down" },
      { "<C-k>", [[<Cmd>wincmd k<CR>]], mode = "t", desc = "Navigate up" },
      { "<C-l>", [[<Cmd>wincmd l<CR>]], mode = "t", desc = "Navigate right" },
    },
    config = function()
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        persist_mode = true,
        direction = "float",
        close_on_exit = true,
        shell = vim.o.shell,
        auto_scroll = true,
        float_opts = {
          border = "curved",
          width = function()
            return math.floor(vim.o.columns * 0.8)
          end,
          height = function()
            return math.floor(vim.o.lines * 0.8)
          end,
          winblend = 3,
        },
        winbar = {
          enabled = false,
          name_formatter = function(term)
            return term.name
          end,
        },
        on_create = function(t)
          -- Enable URL clicking in terminal
          vim.api.nvim_buf_set_option(t.bufnr, 'mouse', 'a')
          
          -- Set up URL pattern matching and click handler
          vim.api.nvim_create_autocmd("BufEnter", {
            buffer = t.bufnr,
            callback = function()
              vim.api.nvim_buf_set_keymap(t.bufnr, 'n', '<LeftMouse>', '<LeftMouse><cmd>lua OpenUrlUnderCursor()<cr>', 
                { noremap = true, silent = true })
              vim.api.nvim_buf_set_keymap(t.bufnr, 'n', 'gx', '<cmd>lua OpenUrlUnderCursor()<cr>', 
                { noremap = true, silent = true, desc = "Open URL under cursor" })
            end,
          })
        end,
      })
      
      -- Global function to open URLs under cursor
      function OpenUrlUnderCursor()
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        
        -- URL pattern matching (http/https)
        local url_pattern = "https?://[%w-_%.%?%.:/%+=&%%~#]*[%w-_/%%~#]"
        local start_pos = 1
        
        while true do
          local url_start, url_end = string.find(line, url_pattern, start_pos)
          if not url_start then break end
          
          -- Check if cursor is within this URL
          if col >= url_start - 1 and col <= url_end - 1 then
            local url = string.sub(line, url_start, url_end)
            
            -- Detect OS and open URL accordingly
            local open_cmd
            if vim.fn.has("mac") == 1 then
              open_cmd = "open"
            elseif vim.fn.has("unix") == 1 then
              open_cmd = "xdg-open"
            elseif vim.fn.has("win32") == 1 then
              open_cmd = "start"
            else
              vim.notify("Unsupported OS for URL opening", vim.log.levels.ERROR)
              return
            end
            
            -- Execute the command to open URL
            vim.fn.jobstart({ open_cmd, url }, { detach = true })
            vim.notify("Opening URL: " .. url, vim.log.levels.INFO)
            return
          end
          
          start_pos = url_end + 1
        end
        
        vim.notify("No URL found under cursor", vim.log.levels.WARN)
      end
      
      -- Custom terminals
      local Terminal = require("toggleterm.terminal").Terminal
      
      -- LazyGit terminal
      local lazygit = Terminal:new({
        cmd = "lazygit",
        dir = "git_dir",
        direction = "float",
        float_opts = {
          border = "double",
        },
        on_open = function(term)
          vim.cmd("startinsert!")
          vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
          -- Disable Esc mapping for LazyGit buffer to avoid mode conflicts
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<Esc>", { noremap = true, silent = true })
        end,
        on_close = function(term)
          vim.cmd("startinsert!")
        end,
      })
      
      function _LAZYGIT_TOGGLE()
        lazygit:toggle()
      end
      
      -- Node terminal
      local node = Terminal:new({ cmd = "node", hidden = true })
      
      function _NODE_TOGGLE()
        node:toggle()
      end
      
      -- Python terminal
      local python = Terminal:new({ cmd = "python3", hidden = true })
      
      function _PYTHON_TOGGLE()
        python:toggle()
      end
      
      -- Btop terminal
      local btop = Terminal:new({ cmd = "btop", hidden = true })
      
      function _BTOP_TOGGLE()
        btop:toggle()
      end
    end,
  },
  
  -- Tmux integration
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Navigate previous" },
    },
  },
}