-- Terminal Monitor: Watches terminal output and triggers pattern matching
-- Processes new lines as they appear and shows matched files in ghost window

local state = require('radish-mcp.state')
local pattern_registry = require('radish-mcp.pattern-registry')
local ghost_window = require('radish-mcp.ghost-window')

local M = {}

-- Configuration
M.config = {
  poll_interval_ms = 500,  -- How often to check for new lines
  auto_show_ghost = true,  -- Automatically show files in ghost window
  batch_size = 50,         -- Max lines to process at once
  wrap_lookahead = 2,      -- Number of lines to join for handling wraps
  auto_start = true,       -- Auto-start monitoring when terminal detected
}

-- Timer for polling
local poll_timer = nil

-- Find a terminal buffer
local function find_terminal_buffer()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
      local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
      if buftype == 'terminal' then
        return buf
      end
    end
  end
  return nil
end

-- Process a single line from terminal
-- Returns: true if processing should stop (handler consumed it)
local function process_line(line, line_number, buf, total_lines)
  -- Create context for handlers
  local context = {
    line_number = line_number,
    terminal_buf = state.get_terminal(),
    get_joined_line = function(lookahead)
      -- Join this line with next N lines to handle terminal wrapping
      lookahead = lookahead or M.config.wrap_lookahead
      local end_line = math.min(line_number + lookahead, total_lines)
      if end_line <= line_number then
        return line
      end

      -- Get next lines (0-indexed API)
      local next_lines = vim.api.nvim_buf_get_lines(buf, line_number, end_line, false)

      -- Join with current line
      local joined = line
      for _, next_line in ipairs(next_lines) do
        joined = joined .. next_line
      end

      return joined
    end,
    show_in_ghost = function(filepath, line_num)
      if M.config.auto_show_ghost then
        ghost_window.show_file(filepath, line_num)
        state.add_ghost_file(filepath, line_num)
      end
    end,
  }

  -- Let pattern registry process the line
  local result = pattern_registry.process_line(line, context)

  return result
end

-- Process new lines from terminal buffer
local function process_new_lines()
  -- If we don't have a terminal yet and auto-start is enabled, try to find one
  if not state.has_terminal() and M.config.auto_start then
    local terminal_buf = find_terminal_buffer()
    if terminal_buf then
      state.set_terminal(terminal_buf)
      state.set_monitoring(true)
      vim.notify("Ghost mode: Auto-detected terminal buffer", vim.log.levels.INFO)
    else
      return  -- No terminal yet, keep waiting
    end
  end

  -- Check if monitoring is active and we have a valid terminal
  if not state.is_monitoring() or not state.has_terminal() then
    return
  end

  local buf = state.get_terminal()

  -- Get total line count in buffer
  local ok, line_count = pcall(vim.api.nvim_buf_line_count, buf)
  if not ok then
    -- Buffer became invalid
    M.stop()
    vim.notify("Terminal buffer became invalid, stopping monitor", vim.log.levels.WARN)
    return
  end

  local last_processed = state.get_processed_line()

  -- Calculate which lines are new
  local start_line = last_processed + 1
  local end_line = math.min(start_line + M.config.batch_size - 1, line_count)

  -- Nothing new to process
  if start_line > line_count then
    return
  end

  -- Get new lines (0-indexed for API)
  local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)

  -- Process each line
  for i, line in ipairs(lines) do
    local line_number = start_line + i - 1
    local should_stop = process_line(line, line_number, buf, line_count)

    -- Update state
    state.update_processed_line(line_number)

    -- If handler requested stop, break
    if should_stop then
      break
    end
  end
end

-- Start monitoring terminal
-- @param buf_id number: optional buffer ID to monitor (uses current if not provided)
function M.start(buf_id)
  -- Set terminal buffer
  if buf_id then
    if not state.set_terminal(buf_id) then
      return false
    end
  elseif not state.has_terminal() then
    -- Use current buffer
    local current_buf = vim.api.nvim_get_current_buf()
    if not state.set_terminal(current_buf) then
      return false
    end
  end

  -- Enable monitoring
  state.set_monitoring(true)

  -- Start polling timer if not already running
  if not poll_timer then
    poll_timer = vim.loop.new_timer()
    poll_timer:start(
      M.config.poll_interval_ms,  -- Initial delay
      M.config.poll_interval_ms,  -- Repeat interval
      vim.schedule_wrap(process_new_lines)
    )
    vim.notify(
      string.format("Terminal monitoring started (polling every %dms)", M.config.poll_interval_ms),
      vim.log.levels.INFO
    )
  end

  return true
end

-- Stop monitoring terminal
function M.stop()
  state.set_monitoring(false)

  if poll_timer then
    poll_timer:stop()
    poll_timer:close()
    poll_timer = nil
    vim.notify("Terminal monitoring stopped", vim.log.levels.INFO)
  end
end

-- Toggle monitoring on/off
function M.toggle()
  if state.is_monitoring() then
    M.stop()
  else
    M.start()
  end
end

-- Reset processing to beginning of buffer
function M.reset()
  state.reset_processing()
  vim.notify("Processing position reset to beginning", vim.log.levels.INFO)
end

-- Process entire buffer from beginning (one-time scan)
function M.scan_all()
  if not state.has_terminal() then
    vim.notify("No terminal buffer set", vim.log.levels.ERROR)
    return false
  end

  -- Reset to beginning
  state.update_processed_line(0)

  -- Process all lines in batches
  local buf = state.get_terminal()
  local line_count = vim.api.nvim_buf_line_count(buf)

  vim.notify(
    string.format("Scanning all %d lines in terminal buffer...", line_count),
    vim.log.levels.INFO
  )

  while state.get_processed_line() < line_count do
    process_new_lines()
  end

  vim.notify("Full buffer scan complete", vim.log.levels.INFO)
  return true
end

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Auto-start monitoring if enabled
  if M.config.auto_start then
    -- Start timer that looks for terminal buffers
    poll_timer = vim.loop.new_timer()
    poll_timer:start(
      M.config.poll_interval_ms,
      M.config.poll_interval_ms,
      vim.schedule_wrap(process_new_lines)
    )
    vim.notify("Ghost mode: Auto-start enabled, waiting for terminal...", vim.log.levels.INFO)
  end
end

-- Get current status
function M.status()
  print("=== Terminal Monitor Status ===")
  state.show_terminal_status()
  print(string.format("Poll Interval: %dms", M.config.poll_interval_ms))
  print(string.format("Auto Show Ghost: %s", M.config.auto_show_ghost and "yes" or "no"))
  print(string.format("Batch Size: %d lines", M.config.batch_size))
  print(string.format("Timer Active: %s", poll_timer and "yes" or "no"))
end

return M
