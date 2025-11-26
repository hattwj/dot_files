-- vim_status tool
local M = {}

M.schema = {
  name = "vim_status",
  description = "Get comprehensive Neovim status",
  inputSchema = {
    type = "object",
    properties = vim.empty_dict()
  }
}

M.handler = function(arguments)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local mode = vim.api.nvim_get_mode().mode
  local filename = vim.api.nvim_buf_get_name(0)
  local cwd = vim.fn.getcwd()

  local status = {
    cursorPosition = cursor,
    mode = mode,
    fileName = filename,
    cwd = cwd,
    buffers = #vim.api.nvim_list_bufs()
  }

  return {
    content = {
      {
        type = "text",
        text = vim.json.encode(status)
      }
    }
  }
end

return M
