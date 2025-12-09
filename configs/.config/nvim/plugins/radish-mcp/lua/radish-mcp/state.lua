-- Shared state for Radish MCP server
local M = {}

-- Preview window state
M.preview = {
  win = nil,
  buf = nil,
  file = nil,
  changes = nil,
  mode = "float",
  status = "none",  -- "none", "pending", "accepted", "rejected"
  result_message = nil
}

-- Abort state - user can signal to pause AI work
M.abort = {
  requested = false,
  message = nil,
  timestamp = nil
}

-- Change tracking state
M.changes = {
  modified = {},  -- Files with unsaved changes
  saved = {},     -- Files saved since last reset
  opened = {},    -- Newly opened buffers since last reset
}

-- Terminal monitoring state
M.terminal = {
  buf = nil,              -- Buffer ID of monitored terminal
  last_processed_line = 0, -- Last line number processed
  is_monitoring = false,  -- Whether monitoring is active
  ghost_files = {},       -- History of files shown in ghost window
  max_ghost_history = 100, -- Keep last N ghost file entries
}

-- Reset change tracker
function M.reset_changes()
  M.changes.modified = {}
  M.changes.saved = {}
  M.changes.opened = {}
end

-- Request abort
function M.request_abort(message)
  M.abort.requested = true
  M.abort.message = message or "User requested pause"
  M.abort.timestamp = os.time()
  vim.notify("Radish: Abort signal sent - " .. M.abort.message, vim.log.levels.WARN)
end

-- Clear abort
function M.clear_abort()
  M.abort.requested = false
  M.abort.message = nil
  M.abort.timestamp = nil
end

-- Terminal monitoring functions

-- Set which terminal buffer to monitor
function M.set_terminal(buf_id)
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
    vim.notify("Invalid terminal buffer ID: " .. tostring(buf_id), vim.log.levels.ERROR)
    return false
  end

  M.terminal.buf = buf_id
  M.terminal.last_processed_line = 0
  vim.notify(string.format("Monitoring terminal buffer %d", buf_id), vim.log.levels.INFO)
  return true
end

-- Get current monitored terminal buffer
function M.get_terminal()
  return M.terminal.buf
end

-- Check if we have a valid terminal buffer
function M.has_terminal()
  return M.terminal.buf and vim.api.nvim_buf_is_valid(M.terminal.buf)
end

-- Set monitoring state
function M.set_monitoring(enabled)
  M.terminal.is_monitoring = enabled
  if enabled then
    vim.notify("Terminal monitoring enabled", vim.log.levels.INFO)
  else
    vim.notify("Terminal monitoring disabled", vim.log.levels.INFO)
  end
end

-- Check if monitoring is active
function M.is_monitoring()
  return M.terminal.is_monitoring
end

-- Update last processed line
function M.update_processed_line(line_number)
  if type(line_number) ~= "number" or line_number < 0 then
    vim.notify("Invalid line number: " .. tostring(line_number), vim.log.levels.ERROR)
    return false
  end

  M.terminal.last_processed_line = line_number
  return true
end

-- Get last processed line number
function M.get_processed_line()
  return M.terminal.last_processed_line
end

-- Reset processing position
function M.reset_processing()
  M.terminal.last_processed_line = 0
  vim.notify("Reset processing position", vim.log.levels.INFO)
end

-- Record file shown in ghost window
function M.add_ghost_file(filepath, line)
  table.insert(M.terminal.ghost_files, {
    filepath = filepath,
    line = line,
    timestamp = os.time(),
  })

  -- Trim history
  while #M.terminal.ghost_files > M.terminal.max_ghost_history do
    table.remove(M.terminal.ghost_files, 1)
  end
end

-- Get ghost file history
function M.get_ghost_history(count)
  count = count or #M.terminal.ghost_files

  local result = {}
  local start = math.max(1, #M.terminal.ghost_files - count + 1)

  for i = start, #M.terminal.ghost_files do
    table.insert(result, M.terminal.ghost_files[i])
  end

  return result
end

-- Clear ghost file history
function M.clear_ghost_history()
  M.terminal.ghost_files = {}
  vim.notify("Cleared ghost file history", vim.log.levels.INFO)
end

-- Get terminal monitoring status
function M.show_terminal_status()
  print("=== Terminal Monitor State ===")
  print(string.format("Terminal Buffer: %s", M.terminal.buf or "none"))
  print(string.format("Valid Terminal: %s", M.has_terminal() and "yes" or "no"))
  print(string.format("Monitoring: %s", M.terminal.is_monitoring and "enabled" or "disabled"))
  print(string.format("Last Processed Line: %d", M.terminal.last_processed_line))
  print(string.format("Ghost History: %d entries", #M.terminal.ghost_files))
end

return M
