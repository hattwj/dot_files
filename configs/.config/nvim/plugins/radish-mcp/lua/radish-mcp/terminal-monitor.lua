-- Terminal Monitor - Watches terminal buffers for file operation announcements
local file_watcher = require("radish-mcp.file-watcher")
local ghost_display = require("radish-mcp.ghost-display")
local M = {}

-- Default configuration
M.config = {
  enabled = true,
  terminal_patterns = { "terminal://wasabi" },
  file_patterns = {
    -- Match Wasabi's actual output format
    modify = "Auto%-accepting changes to ([^:]+):",
    create = "Creating file: ([^:]+)",
    delete = "Deleting file: ([^:]+)",
  },
  ghost_mode = {
    enabled = true,
    auto_open_files = true,
    highlight_duration = 2000,
    highlight_color = "#4a4a00",
  }
}

-- Track last processed line per buffer
local last_line_seen = {}

-- Check if buffer matches terminal patterns
local function matches_terminal_pattern(bufname)
  for _, pattern in ipairs(M.config.terminal_patterns) do
    if bufname:match(pattern) then
      return true
    end
  end
  return false
end

-- Parse terminal line for file operations
local function parse_line(line)
  for op_type, pattern in pairs(M.config.file_patterns) do
    local filepath = line:match(pattern)
    if filepath then
      return {
        operation = op_type,
        file = filepath,
        timestamp = os.time()
      }
    end
  end
  return nil
end

-- Handle detected file operation
local function handle_file_operation(operation)
  local file = operation.file

  -- Set up file watch
  file_watcher.watch(file, function(event)
    -- File changed on disk
    ghost_display.show_change(file, event)
  end)

  -- Optionally auto-open file
  if M.config.ghost_mode.enabled and M.config.ghost_mode.auto_open_files then
    ghost_display.open_file(file)
  end

  -- Log the operation
  vim.notify(
    string.format("Monitoring %s: %s", operation.operation, file),
    vim.log.levels.INFO
  )
end

-- Process new lines in terminal buffer
local function process_terminal_buffer(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  if not matches_terminal_pattern(bufname) then
    return
  end

  -- Get buffer line count
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local last_seen = last_line_seen[bufnr] or 0

  -- Process only new lines
  if line_count > last_seen then
    local new_lines = vim.api.nvim_buf_get_lines(bufnr, last_seen, line_count, false)

    for _, line in ipairs(new_lines) do
      local operation = parse_line(line)
      if operation then
        handle_file_operation(operation)
      end
    end

    last_line_seen[bufnr] = line_count
  end
end

-- Set up autocmds for terminal monitoring
function M.setup(config)
  -- Merge user config with defaults
  M.config = vim.tbl_deep_extend("force", M.config, config or {})

  if not M.config.enabled then
    return
  end

  -- Create autocmd group
  local group = vim.api.nvim_create_augroup("RadishTerminalMonitor", { clear = true })

  -- Monitor terminal buffer changes
  vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI", "TextChangedP"}, {
    group = group,
    pattern = "*",
    callback = function(args)
      local bufnr = args.buf
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })

      if buftype == "terminal" then
        process_terminal_buffer(bufnr)
      end
    end
  })

  -- Clean up when buffer is deleted
  vim.api.nvim_create_autocmd("BufDelete", {
    group = group,
    pattern = "*",
    callback = function(args)
      last_line_seen[args.buf] = nil
    end
  })

  vim.notify("Radish Terminal Monitor enabled", vim.log.levels.INFO)
end

return M
