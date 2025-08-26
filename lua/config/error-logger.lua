-- Error Logger for Neovim
-- Captures all errors and writes them to a log file for later analysis

local M = {}

-- Configuration
local log_dir = vim.fn.stdpath("state") .. "/nvim-errors"
local log_file = log_dir .. "/error.log"
local max_log_size = 10 * 1024 * 1024 -- 10MB max size before rotation
local max_backup_files = 5

-- Ensure log directory exists
vim.fn.mkdir(log_dir, "p")

-- Function to rotate log files if they get too large
local function rotate_log_if_needed()
  local stat = vim.loop.fs_stat(log_file)
  if stat and stat.size > max_log_size then
    -- Rotate existing backup files
    for i = max_backup_files - 1, 1, -1 do
      local old_name = log_file .. "." .. i
      local new_name = log_file .. "." .. (i + 1)
      if vim.fn.filereadable(old_name) == 1 then
        vim.fn.rename(old_name, new_name)
      end
    end
    -- Move current log to .1
    vim.fn.rename(log_file, log_file .. ".1")
  end
end

-- Function to write to log file
local function write_to_log(level, msg, source)
  rotate_log_if_needed()
  
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  local log_entry = string.format(
    "[%s] [%s] %s%s\n",
    timestamp,
    level,
    source and ("(" .. source .. ") ") or "",
    msg
  )
  
  local file, err = io.open(log_file, "a")
  if file then
    file:write(log_entry)
    file:close()
  else
    -- Fallback: print to stderr if can't write to file
    vim.schedule(function()
      print("Error logger: Could not write to log file: " .. (err or "unknown error"))
    end)
  end
end

-- Store the original vim.notify function
local original_notify = vim.notify

-- Override vim.notify to capture all notifications
function vim.notify(msg, level, opts)
  opts = opts or {}
  level = level or vim.log.levels.INFO
  
  -- Convert message to string if it's not already
  local msg_str = type(msg) == "string" and msg or vim.inspect(msg)
  
  -- Determine the source
  local source = opts.title or "General"
  
  -- Log errors and warnings
  if level >= vim.log.levels.WARN then
    local level_str = level == vim.log.levels.ERROR and "ERROR" or
                      level == vim.log.levels.WARN and "WARN" or
                      level == vim.log.levels.INFO and "INFO" or
                      "DEBUG"
    
    write_to_log(level_str, msg_str, source)
  end
  
  -- Call the original notify function
  return original_notify(msg, level, opts)
end

-- LSP error handler
local function setup_lsp_error_handler()
  -- Override LSP handlers to log errors
  local handlers = {
    ["window/showMessage"] = vim.lsp.handlers["window/showMessage"],
    ["window/logMessage"] = vim.lsp.handlers["window/logMessage"],
  }
  
  vim.lsp.handlers["window/showMessage"] = function(err, result, ctx, config)
    if err then
      write_to_log("ERROR", "LSP showMessage error: " .. vim.inspect(err), "LSP")
    end
    if result and result.type == vim.lsp.protocol.MessageType.Error then
      write_to_log("ERROR", "LSP: " .. (result.message or "Unknown error"), "LSP")
    elseif result and result.type == vim.lsp.protocol.MessageType.Warning then
      write_to_log("WARN", "LSP: " .. (result.message or "Unknown warning"), "LSP")
    end
    return handlers["window/showMessage"](err, result, ctx, config)
  end
  
  vim.lsp.handlers["window/logMessage"] = function(err, result, ctx, config)
    if err then
      write_to_log("ERROR", "LSP logMessage error: " .. vim.inspect(err), "LSP")
    end
    if result and result.type == vim.lsp.protocol.MessageType.Error then
      write_to_log("ERROR", "LSP Log: " .. (result.message or "Unknown error"), "LSP")
    elseif result and result.type == vim.lsp.protocol.MessageType.Warning then
      write_to_log("WARN", "LSP Log: " .. (result.message or "Unknown warning"), "LSP")
    end
    return handlers["window/logMessage"](err, result, ctx, config)
  end
  
  -- Log LSP client errors
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client then
        write_to_log("INFO", "LSP attached: " .. client.name, "LSP")
      end
    end,
  })
  
  -- Capture LSP errors during initialization
  local original_start_client = vim.lsp.start_client
  vim.lsp.start_client = function(config)
    local client_id = original_start_client(config)
    if not client_id then
      write_to_log("ERROR", "Failed to start LSP client: " .. (config.name or "unknown"), "LSP")
    end
    return client_id
  end
end

-- Setup diagnostic handler to log errors
local function setup_diagnostic_handler()
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function()
      local errors = vim.diagnostic.get(nil, { severity = vim.diagnostic.severity.ERROR })
      for _, diagnostic in ipairs(errors) do
        if diagnostic.source and diagnostic.message then
          -- Only log new errors (implement a simple cache to avoid duplicates)
          local key = diagnostic.source .. ":" .. diagnostic.message .. ":" .. (diagnostic.lnum or 0)
          if not M._logged_diagnostics[key] then
            M._logged_diagnostics[key] = true
            write_to_log("ERROR", "Diagnostic: " .. diagnostic.message, diagnostic.source)
          end
        end
      end
    end,
  })
end

-- Cache for logged diagnostics to avoid duplicates
M._logged_diagnostics = {}

-- Setup error handlers for various Neovim events
local function setup_error_handlers()
  -- Capture general Vim errors
  vim.api.nvim_create_autocmd("User", {
    pattern = "Error",
    callback = function()
      local error_msg = vim.v.errmsg
      if error_msg and error_msg ~= "" then
        write_to_log("ERROR", error_msg, "Vim")
      end
    end,
  })
  
  -- Capture errors during BufReadPost
  vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
      if vim.v.errmsg and vim.v.errmsg ~= "" then
        write_to_log("ERROR", "BufReadPost: " .. vim.v.errmsg, "Buffer")
        vim.v.errmsg = ""
      end
    end,
  })
  
  -- Log plugin loading errors
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyLog",
    callback = function()
      if vim.v.errmsg and vim.v.errmsg ~= "" then
        write_to_log("ERROR", "Plugin loading: " .. vim.v.errmsg, "Lazy")
      end
    end,
  })
end

-- Function to read and display recent errors
function M.show_recent_errors(lines)
  lines = lines or 50
  
  if vim.fn.filereadable(log_file) == 0 then
    vim.notify("No error log file found", vim.log.levels.INFO)
    return
  end
  
  local cmd = string.format("tail -n %d %s", lines, log_file)
  local output = vim.fn.system(cmd)
  
  -- Create a new buffer to show errors
  vim.cmd("new")
  vim.cmd("setlocal buftype=nofile")
  vim.cmd("setlocal bufhidden=wipe")
  vim.cmd("setlocal noswapfile")
  vim.cmd("setlocal nowrap")
  vim.cmd("file NvimErrorLog")
  
  -- Set the content
  local lines_table = vim.split(output, "\n")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines_table)
  
  -- Add syntax highlighting
  vim.cmd("syntax match ErrorLogTimestamp /\\[\\d\\{4\\}-\\d\\{2\\}-\\d\\{2\\} \\d\\{2\\}:\\d\\{2\\}:\\d\\{2\\}\\]/")
  vim.cmd("syntax match ErrorLogError /\\[ERROR\\]/")
  vim.cmd("syntax match ErrorLogWarn /\\[WARN\\]/")
  vim.cmd("syntax match ErrorLogInfo /\\[INFO\\]/")
  vim.cmd("syntax match ErrorLogSource /(.*)/")
  
  vim.cmd("highlight ErrorLogTimestamp guifg=#808080")
  vim.cmd("highlight ErrorLogError guifg=#ff0000")
  vim.cmd("highlight ErrorLogWarn guifg=#ffaa00")
  vim.cmd("highlight ErrorLogInfo guifg=#00aa00")
  vim.cmd("highlight ErrorLogSource guifg=#00aaff")
  
  -- Go to the end of the buffer
  vim.cmd("normal! G")
end

-- Function to clear the error log
function M.clear_log()
  local file = io.open(log_file, "w")
  if file then
    file:write("")
    file:close()
    vim.notify("Error log cleared", vim.log.levels.INFO)
  end
end

-- Function to get log file path
function M.get_log_path()
  return log_file
end

-- Initialize the error logger
function M.setup()
  setup_lsp_error_handler()
  setup_diagnostic_handler()
  setup_error_handlers()
  
  -- Log that error logging has been initialized
  write_to_log("INFO", "Error logger initialized", "System")
  
  -- Create user commands
  vim.api.nvim_create_user_command("ShowErrors", function(opts)
    M.show_recent_errors(opts.args ~= "" and tonumber(opts.args) or 50)
  end, { nargs = "?" })
  
  vim.api.nvim_create_user_command("ClearErrorLog", function()
    M.clear_log()
  end, {})
  
  vim.api.nvim_create_user_command("ErrorLogPath", function()
    print("Error log: " .. M.get_log_path())
  end, {})
end

return M