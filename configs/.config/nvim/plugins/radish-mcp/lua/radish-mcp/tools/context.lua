-- vim_get_context tool - The metadata side-band channel
local state = require("radish-mcp.state")
local preview_window = require("radish-mcp.preview.window")
local M = {}

M.schema = {
  name = "vim_get_context",
  description = "Get comprehensive editor context including preview status, open buffers, changed files, current state, and abort signals",
  inputSchema = {
    type = "object",
    properties = {
      reset_changes = {
        type = "boolean",
        description = "Reset the tracked changes after returning them (default: false)"
      },
      clear_abort = {
        type = "boolean",
        description = "Clear the abort signal after reading it (default: false)"
      },
      clear_preview = {
        type = "boolean",
        description = "Clear and close the preview after reading status (SYN-ACK, default: false)"
      }
    }
  }
}

M.handler = function(arguments)
  local reset_changes = arguments.reset_changes or false
  local clear_abort = arguments.clear_abort or false
  local clear_preview = arguments.clear_preview or false

  -- Get current buffer info
  local current_buf = vim.api.nvim_get_current_buf()
  local current_file = vim.api.nvim_buf_get_name(current_buf)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local mode = vim.api.nvim_get_mode().mode
  local cwd = vim.fn.getcwd()

  -- Get all open buffers
  local buffers = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name ~= "" then
        local modified = vim.api.nvim_buf_get_option(bufnr, 'modified')
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')

        table.insert(buffers, {
          name = name,
          modified = modified,
          lines = line_count,
          buftype = buftype,
          is_current = bufnr == current_buf
        })

        -- Track modified files
        if modified and buftype == "" then
          state.changes.modified[name] = true
        end
      end
    end
  end

  -- Build context object
  local context = {
    -- Abort signal - user wants to pause AI work
    abort = {
      requested = state.abort.requested,
      message = state.abort.message,
      timestamp = state.abort.timestamp
    },

    -- Preview state
    preview = {
      status = state.preview.status,
      file = state.preview.file,
      is_open = state.preview.win ~= nil and vim.api.nvim_win_is_valid(state.preview.win),
      message = state.preview.result_message
    },

    -- Current editor state
    editor = {
      current_file = current_file,
      cursor = cursor,
      mode = mode,
      cwd = cwd
    },

    -- All open buffers
    buffers = buffers,

    -- Change tracking
    changes = {
      modified = vim.tbl_keys(state.changes.modified),
      saved = vim.tbl_keys(state.changes.saved),
      opened = vim.tbl_keys(state.changes.opened)
    }
  }

  -- Clear abort signal if requested
  if clear_abort and state.abort.requested then
    state.clear_abort()
  end

  -- Reset tracking if requested
  if reset_changes then
    state.reset_changes()
  end

  -- Clear preview after acknowledgment (SYN-ACK)
  if clear_preview and state.preview.status ~= "none" then
    preview_window.close()
  end

  return {
    content = {
      {
        type = "text",
        text = vim.json.encode(context)
      }
    }
  }
end

return M
