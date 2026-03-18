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

  -- Snapshot :messages before execution to detect new print() output
  local msgs_before = vim.fn.execute("messages")

  -- Use vim.fn.execute() which captures via :redir (catches :echo, :ls, etc.)
  local success, redir_output = pcall(vim.fn.execute, command)

  if not success then
    return {
      content = {
        {
          type = "text",
          text = "Error executing command: " .. tostring(redir_output)
        }
      }
    }
  end

  -- Check :messages for anything new (e.g. from lua print())
  local msgs_after = vim.fn.execute("messages")
  local new_msgs = ""
  if #msgs_after > #msgs_before then
    new_msgs = vim.trim(msgs_after:sub(#msgs_before + 1))
  end

  -- Combine: redir output first, then any new messages
  local output = vim.trim(redir_output or "")
  if new_msgs ~= "" then
    if output ~= "" then
      output = output .. "\n" .. new_msgs
    else
      output = new_msgs
    end
  end

  local text = output ~= "" and output or ("Command executed: " .. command)
  return {
    content = {
      {
        type = "text",
        text = text
      }
    }
  }
end

return M
