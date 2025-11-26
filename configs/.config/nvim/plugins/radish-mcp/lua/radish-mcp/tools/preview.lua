-- Preview tools: vim_preview_change and vim_get_preview_status
local state = require("radish-mcp.state")
local preview_window = require("radish-mcp.preview.window")
local M = {}

-- Export multiple tool schemas
M.schemas = {
  {
    name = "vim_preview_change",
    description = "Preview changes to a file before applying",
    inputSchema = {
      type = "object",
      properties = {
        file = {
          type = "string",
          description = "File path to preview changes for"
        },
        changes = {
          type = "string",
          description = "Content changes to preview"
        },
        mode = {
          type = "string",
          enum = {"inline", "split", "float"},
          description = "How to display the preview"
        }
      },
      required = {"file", "changes"}
    }
  },
  {
    name = "vim_get_preview_status",
    description = "Get the status of the last preview (none, pending, accepted, or rejected)",
    inputSchema = {
      type = "object",
      properties = vim.empty_dict()
    }
  }
}

-- Export multiple handlers
M.handlers = {}

M.handlers["vim_preview_change"] = function(arguments)
  local file = arguments.file
  local changes = arguments.changes
  local mode = arguments.mode or "inline"

  if not file or not changes then
    return {
      content = {
        {
          type = "text",
          text = "Error: file and changes parameters required"
        }
      }
    }
  end

  -- Open inline diff preview (new implementation)
  local result_text = preview_window.open(file, changes, mode)

  return {
    content = {
      {
        type = "text",
        text = result_text
      }
    }
  }
end

M.handlers["vim_get_preview_status"] = function(arguments)
  return {
    content = {
      {
        type = "text",
        text = vim.json.encode({
          status = state.preview.status,
          file = state.preview.file,
          message = state.preview.result_message,
          is_open = state.preview.win ~= nil and vim.api.nvim_win_is_valid(state.preview.win)
        })
      }
    }
  }
end

return M
