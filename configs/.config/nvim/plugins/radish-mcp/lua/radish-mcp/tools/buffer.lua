-- vim_buffer tool
local M = {}

M.schema = {
  name = "vim_buffer",
  description = "Get buffer contents with line numbers. Can read multiple buffers at once (max 20)",
  inputSchema = {
    type = "object",
    properties = {
      filename = {
        type = "string",
        description = "Optional filename to view specific buffer (single buffer mode)"
      },
      files = {
        type = "array",
        description = "Array of filenames to read (multi-buffer mode). Max 20 files.",
        items = {
          type = "string"
        },
        maxItems = 20
      }
    }
  }
}

M.handler = function(arguments)
  local filename = arguments.filename
  local files = arguments.files

  -- Multi-buffer mode
  if files then
    if type(files) ~= "table" then
      return {
        content = {
          {
            type = "text",
            text = "Error: 'files' must be an array"
          }
        }
      }
    end

    if #files > 20 then
      return {
        content = {
          {
            type = "text",
            text = "Error: Maximum 20 files allowed, got " .. #files
          }
        }
      }
    end

    if #files == 0 then
      return {
        content = {
          {
            type = "text",
            text = "Error: 'files' array is empty"
          }
        }
      }
    end

    -- Read all buffers
    local results = {}
    local success_count = 0
    local error_count = 0

    for i, fname in ipairs(files) do
      local result = M.read_single_buffer(fname)

      if result.success then
        success_count = success_count + 1
        table.insert(results, string.format("=== File %d/%d: %s (%d lines) ===",
          i, #files, fname, result.line_count))
        table.insert(results, result.content)
        table.insert(results, "") -- Blank line separator
      else
        error_count = error_count + 1
        table.insert(results, string.format("=== File %d/%d: %s ===", i, #files, fname))
        table.insert(results, result.message)
        table.insert(results, "") -- Blank line separator
      end
    end

    local summary = string.format(
      "Read %d buffers (%d succeeded, %d failed)\n\n%s",
      #files,
      success_count,
      error_count,
      table.concat(results, "\n")
    )

    return {
      content = {
        {
          type = "text",
          text = summary
        }
      }
    }
  end

  -- Single buffer mode
  local result = M.read_single_buffer(filename)

  if result.success then
    return {
      content = {
        {
          type = "text",
          text = result.content
        }
      }
    }
  else
    return {
      content = {
        {
          type = "text",
          text = result.message
        }
      }
    }
  end
end

-- Internal function to read a single buffer
M.read_single_buffer = function(filename)
  local bufnr = vim.fn.bufnr(filename or "%")

  if bufnr == -1 then
    return {
      success = false,
      message = "Buffer not found: " .. (filename or "current")
    }
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local numbered_lines = {}

  for i, line in ipairs(lines) do
    table.insert(numbered_lines, string.format("%d: %s", i, line))
  end

  return {
    success = true,
    line_count = #lines,
    content = table.concat(numbered_lines, "\n")
  }
end

return M
