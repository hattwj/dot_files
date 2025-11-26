-- File operations: open_file
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
    local current_buf = vim.api.nvim_get_current_buf()
    local current_buftype = vim.api.nvim_get_option_value("buftype", { buf = current_buf })

    -- If we're in a terminal, don't stomp on it - open in a split or find another window
    if current_buftype == "terminal" then
      -- Try to find a non-terminal window
      local found_window = false
      local windows = vim.api.nvim_list_wins()

      for _, win in ipairs(windows) do
        local win_buf = vim.api.nvim_win_get_buf(win)
        local win_buftype = vim.api.nvim_get_option_value("buftype", { buf = win_buf })

        -- Found a normal window (not terminal, not special)
        if win_buftype == "" then
          vim.api.nvim_set_current_win(win)
          found_window = true
          break
        end
      end

      -- No normal window found, create a split with smart positioning
      if not found_window then
        -- Detect terminal position and create split on opposite side
        local current_win = vim.api.nvim_get_current_win()
        local current_pos = vim.api.nvim_win_get_position(current_win)
        local current_width = vim.api.nvim_win_get_width(current_win)
        local current_height = vim.api.nvim_win_get_height(current_win)

        -- Check if there are other windows to determine position
        local has_left = false
        local has_right = false
        local has_top = false
        local has_bottom = false

        for _, win in ipairs(windows) do
          if win ~= current_win then
            local pos = vim.api.nvim_win_get_position(win)

            -- Check horizontal position
            if pos[2] < current_pos[2] then
              has_left = true
            elseif pos[2] > current_pos[2] then
              has_right = true
            end

            -- Check vertical position
            if pos[1] < current_pos[1] then
              has_top = true
            elseif pos[1] > current_pos[1] then
              has_bottom = true
            end
          end
        end

        -- Decide split direction based on terminal position
        -- If terminal is on the right, split to the left (and vice versa)
        -- Prefer vertical splits over horizontal
        if has_left and not has_right then
          -- Terminal is on the right, split to the left
          vim.cmd("leftabove vsplit")
        elseif has_right and not has_left then
          -- Terminal is on the left, split to the right
          vim.cmd("rightbelow vsplit")
        elseif has_top and not has_bottom then
          -- Terminal is on the bottom, split above
          vim.cmd("leftabove split")
        elseif has_bottom and not has_top then
          -- Terminal is on the top, split below
          vim.cmd("rightbelow split")
        elseif current_pos[2] == 0 then
          -- Terminal is leftmost, split to the right
          vim.cmd("rightbelow vsplit")
        else
          -- Terminal is rightmost or unknown, split to the left
          vim.cmd("leftabove vsplit")
        end
      end
    end

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
