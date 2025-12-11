-- File operations: open_file
local window_manager = require("radish-mcp.window-manager")
local M = {}

M.schema = {
  name = "vim_file_open",
  description = "Open a file in Neovim for viewing or editing. Can open multiple files at once (max 20)",
  inputSchema = {
    type = "object",
    properties = {
      file = {
        type = "string",
        description = "File path to open (single file mode)"
      },
      files = {
        type = "array",
        description = "Array of file paths to open (multi-file mode). Max 20 files.",
        items = {
          oneOf = {
            { type = "string" },
            {
              type = "object",
              properties = {
                file = { type = "string" },
                line = { type = "number" },
                create = { type = "boolean" }
              },
              required = { "file" }
            }
          }
        },
        maxItems = 20
      },
      line = {
        type = "number",
        description = "Optional line number to jump to (single file mode only)"
      },
      create = {
        type = "boolean",
        description = "Create file if it doesn't exist (single file mode, default: false)"
      }
    },
  }
}

M.handler = function(arguments)
  -- Trigger file open hook if it exists
  if M.on_file_open then
    vim.schedule(function()
      M.on_file_open(arguments)
    end)
  end

  local file = arguments.file
  local files = arguments.files
  local line = arguments.line
  local create = arguments.create or false

  -- Validate input: need either file or files
  if not file and not files then
    return {
      content = {
        {
          type = "text",
          text = "Error: either 'file' or 'files' parameter required"
        }
      }
    }
  end

  -- Validate multi-file mode
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
  end  -- Close validation block for 'if files then' at line 64

  -- Multi-file mode
  if files then
    local results = {}
    local success_count = 0
    local error_count = 0

    for i, file_spec in ipairs(files) do
      -- Normalize file spec (string or object)
      local f, l, c
      if type(file_spec) == "string" then
        f = file_spec
        l = nil
        c = false
      else
        f = file_spec.file
        l = file_spec.line
        c = file_spec.create or false
      end

      -- Open the file using single-file logic
      local result = M.open_single_file(f, l, c)

      if result.success then
        success_count = success_count + 1
        table.insert(results, string.format("%d. ✓ %s", i, result.message))
      else
        error_count = error_count + 1
        table.insert(results, string.format("%d. ✗ %s", i, result.message))
      end
    end

    local summary = string.format(
      "Opened %d files (%d succeeded, %d failed):\n%s",
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

  -- Single file mode
  local result = M.open_single_file(file, line, create)

  return {
    content = {
      {
        type = "text",
        text = result.message
      }
    }
  }
end

-- Internal function to open a single file
M.open_single_file = function(file, line, create)
  if not file then
    return { success = false, message = "Error: file parameter required" }
  end

  -- Check if file exists
  local exists = vim.fn.filereadable(file) == 1

  if not exists and not create then
    return {
      success = false,
      message = "Error: File does not exist: " .. file .. " (use create=true)"
    }
  end

  -- Smart window selection: avoid stomping on terminal windows
  local success, result = pcall(function()
    -- Use shared window manager to avoid stomping terminal
    window_manager.get_file_window()

    -- Now open the file in the selected/created window
    vim.cmd("edit " .. vim.fn.fnameescape(file))

    -- Jump to line if specified
    if line and line > 0 then
      vim.cmd(":" .. line)
    end

    -- Return focus to terminal if we came from one
    -- Actually, let's keep focus on the opened file so user can see it
    -- They can switch back to terminal with <C-w>w or similar
  end)

  if not success then
    return {
      success = false,
      message = "Error opening file: " .. tostring(result)
    }
  end

  local msg = "Opened: " .. file
  if line then
    msg = msg .. " (line " .. line .. ")"
  end
  if not exists then
    msg = msg .. " [new file]"
  end

  return { success = true, message = msg }
end

return M
