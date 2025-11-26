-- vim_command tool
local M = {}

M.schema = {
  name = "vim_command",
  description = "Execute vim command",
  inputSchema = {
    type = "object",
    properties = {
      command = {
        type = "string",
        description = "Vim command to execute"
      }
    },
    required = {"command"}
  }
}

M.handler = function(arguments)
  local command = arguments.command

  if not command then
    return {
      content = {
        {
          type = "text",
          text = "Error: command parameter required"
        }
      }
    }
  end

  local success, result = pcall(vim.cmd, command)

  if success then
    return {
      content = {
        {
          type = "text",
          text = "Command executed: " .. command
        }
      }
    }
  else
    return {
      content = {
        {
          type = "text",
          text = "Error executing command: " .. tostring(result)
        }
      }
    }
  end
end

return M
