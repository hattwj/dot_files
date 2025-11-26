-- Vim messages tool - Read diagnostic output from :messages
local M = {}

M.schema = {
  name = "vim_messages",
  description = "Read Neovim's :messages output (errors, warnings, diagnostics). Defaults to last 300 lines to prevent overload",
  inputSchema = {
    type = "object",
    properties = {
      lines = {
        type = "number",
        description = "Number of recent lines to return (like tail -n). Default: 300, Max: 1000"
      },
      clear = {
        type = "boolean",
        description = "Clear messages after reading (default: false)"
      }
    }
  }
}

M.handler = function(arguments)
  local num_lines = arguments.lines or 300
  local clear = arguments.clear or false

  -- Cap at 1000 lines to prevent huge responses
  if num_lines > 1000 then
    num_lines = 1000
  end

  -- Capture :messages output
  local messages = vim.fn.execute("messages")

  if not messages or messages == "" then
    return {
      content = {
        {
          type = "text",
          text = "No messages"
        }
      }
    }
  end

  -- Split into lines
  local all_lines = vim.split(messages, "\n", { plain = true })

  -- Tail functionality - get last N lines
  local start_idx = math.max(1, #all_lines - num_lines + 1)
  local result_lines = {}

  for i = start_idx, #all_lines do
    table.insert(result_lines, all_lines[i])
  end

  local output = table.concat(result_lines, "\n")

  -- Add header with line count info
  local header = string.format(
    "--- Messages (showing last %d of %d lines) ---",
    #result_lines,
    #all_lines
  )

  output = header .. "\n" .. output

  -- Clear messages if requested
  if clear then
    vim.cmd("messages clear")
    output = output .. "\n\n--- Messages cleared ---"
  end

  return {
    content = {
      {
        type = "text",
        text = output
      }
    }
  }
end

return M
