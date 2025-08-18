-- Formatting and Linting Configuration

return {
  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      
      -- Configure linters
      lint.linters_by_ft = {
        yaml = { "actionlint" },
        python = { "ruff" },
      }
      
      -- GitHub Actions linting specifically for workflow files
      lint.linters.actionlint = {
        cmd = "actionlint",
        stdin = true,
        args = { "-format", "{{json .}}", "-" },
        stream = "stdout",
        ignore_exitcode = true,
        parser = function(output, _)
          if output == "" then
            return {}
          end
          
          local diagnostics = {}
          local decoded = vim.json.decode(output)
          
          if decoded then
            for _, item in ipairs(decoded) do
              table.insert(diagnostics, {
                lnum = (item.line or 1) - 1,
                col = (item.col or 1) - 1,
                message = item.message or "actionlint error",
                severity = vim.diagnostic.severity.ERROR,
                source = "actionlint",
              })
            end
          end
          
          return diagnostics
        end,
      }
      
      -- Auto-lint on save and text change
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
        callback = function()
          -- Only lint if the file is a GitHub Actions workflow
          local filename = vim.fn.expand("%:t")
          local filepath = vim.fn.expand("%:p")
          
          if filepath:match("%.github/workflows/") or filename:match("%.ya?ml$") then
            lint.try_lint("actionlint")
          else
            lint.try_lint()
          end
        end,
      })
    end,
  },
  
  -- Formatting
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")
      
      conform.setup({
        formatters_by_ft = {
          python = { "autopep8" },
          lua = { "stylua" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          go = { "gofumpt", "goimports" },
          rust = { "rustfmt" },
        },
        
        -- Format on save configuration
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
        
        -- Format after save for slower formatters
        format_after_save = {
          lsp_fallback = true,
        },
      })
      
      -- Manual format keymap
      vim.keymap.set({ "n", "v" }, "<leader>f", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end, { desc = "Format file or range (in visual mode)" })
    end,
  },
}