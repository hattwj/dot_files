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

return M
