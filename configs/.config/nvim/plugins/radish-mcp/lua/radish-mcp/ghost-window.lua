-- Ghost Window Manager: Single reusable split window for displaying AI-edited files
-- Shows files one at a time without creating multiple splits

local state = require('radish-mcp.state')
local M = {}

-- Single persistent window state
local ghost_window = {
  win = nil,  -- Window ID (reused for all files)
  position = "right",  -- "right", "left", "bottom", "top"
  width = 80,  -- For vertical splits
  height = 15,  -- For horizontal splits
}

-- Configuration
M.config = {
  position = "right",
  width = 80,
  height = 15,
  show_line_numbers = true,
  show_diff = false,  -- Whether to automatically show git diff
  auto_position = true,  -- Automatically position opposite to terminal
}

-- Detect terminal window position and return opposite position
-- Returns: "right", "left", "top", "bottom" or nil if can't determine
local function get_opposite_position()
  local terminal_buf = state.get_terminal()
  if not terminal_buf or not vim.api.nvim_buf_is_valid(terminal_buf) then
    return nil
  end

  -- Find terminal window
  local terminal_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == terminal_buf then
      terminal_win = win
      break
    end
  end

  if not terminal_win then
    return nil  -- Terminal not visible
  end

  -- Get terminal window position
  local term_pos = vim.api.nvim_win_get_position(terminal_win)
  local term_row = term_pos[1]
  local term_col = term_pos[2]

  -- Get vim dimensions
  local vim_height = vim.o.lines
  local vim_width = vim.o.columns

  -- Determine terminal position by comparing to center
  local is_left = term_col < vim_width / 2
  local is_top = term_row < vim_height / 2

  -- Return opposite position (prefer vertical splits over horizontal)
  if is_left then
    return "right"
  else
    return "left"
  end
end

-- Find an existing non-terminal split window
-- Returns: window_id or nil if no suitable split found
local function find_existing_split()
  local terminal_buf = state.get_terminal()
  local wins = vim.api.nvim_list_wins()

  -- Need at least 2 windows for a split to exist
  if #wins < 2 then
    return nil
  end

  -- Find a non-terminal, non-floating window
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local is_terminal = (buf == terminal_buf)
    local is_floating = vim.api.nvim_win_get_config(win).relative ~= ""

    if not is_terminal and not is_floating then
      return win
    end
  end

  return nil
end

-- Create or get the ghost window
-- Returns: window_id or nil if creation failed
local function get_or_create_ghost_window()
  -- Check if window still exists and is valid
  if ghost_window.win and vim.api.nvim_win_is_valid(ghost_window.win) then
    return ghost_window.win
  end

  -- Try to find an existing split we can reuse
  local existing_split = find_existing_split()
  if existing_split then
    ghost_window.win = existing_split
    -- Focus the existing split
    vim.api.nvim_set_current_win(existing_split)
    return existing_split
  end

  -- Auto-detect opposite position if enabled
  if M.config.auto_position then
    local opposite = get_opposite_position()
    if opposite then
      ghost_window.position = opposite
    end
  end

  -- Create new window at configured position
  local position = ghost_window.position

  if position == "right" then
    vim.cmd('vertical botright ' .. ghost_window.width .. 'split')
  elseif position == "left" then
    vim.cmd('vertical topleft ' .. ghost_window.width .. 'split')
  elseif position == "bottom" then
    vim.cmd('botright ' .. ghost_window.height .. 'split')
  elseif position == "top" then
    vim.cmd('topleft ' .. ghost_window.height .. 'split')
  else
    vim.notify("Invalid ghost window position: " .. position, vim.log.levels.ERROR)
    return nil
  end

  ghost_window.win = vim.api.nvim_get_current_win()

  -- Mark as ghost window
  vim.api.nvim_win_set_var(ghost_window.win, 'ghost_window', true)

  -- Set window options
  if position == "right" or position == "left" then
    vim.api.nvim_win_set_option(ghost_window.win, 'winfixwidth', true)
  else
    vim.api.nvim_win_set_option(ghost_window.win, 'winfixheight', true)
  end

  vim.api.nvim_win_set_option(ghost_window.win, 'number', M.config.show_line_numbers)
  vim.api.nvim_win_set_option(ghost_window.win, 'relativenumber', false)

  return ghost_window.win
end

-- Show a file in the ghost window
-- @param filepath string: path to file to display
-- @param line_number number: optional line to jump to
-- @param opts table: optional {show_diff=bool}
function M.show_file(filepath, line_number, opts)
  opts = opts or {}

  -- Validate filepath is not empty
  if not filepath or filepath == "" then
    return false
  end

  -- Check if file exists and is a regular file (not a directory)
  local stat = vim.loop.fs_stat(filepath)
  if not stat then
    -- File doesn't exist
    return false
  end

  if stat.type ~= "file" then
    -- It's a directory or other non-file type
    return false
  end

  local win = get_or_create_ghost_window()
  if not win then
    return false
  end

  -- Switch to ghost window and open file
  local previous_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(win)

  -- Open file (reuses window, changes buffer)
  local ok, err = pcall(function()
    vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
  end)

  if not ok then
    vim.notify("Failed to open file: " .. err, vim.log.levels.ERROR)
    vim.api.nvim_set_current_win(previous_win)
    return false
  end

  -- Jump to line if specified
  if line_number and type(line_number) == "number" then
    vim.api.nvim_win_set_cursor(win, {line_number, 0})
    -- Center the line in the window
    vim.api.nvim_win_call(win, function()
      vim.cmd('normal! zz')
    end)
  end

  -- Show git diff if requested
  if opts.show_diff or M.config.show_diff then
    vim.cmd('Git diff ' .. vim.fn.fnameescape(filepath))
  end

  -- Return to previous window
  vim.api.nvim_set_current_win(previous_win)

  return true
end

-- Check if ghost window is open
function M.is_open()
  return ghost_window.win and vim.api.nvim_win_is_valid(ghost_window.win)
end

-- Close ghost window
function M.close()
  if ghost_window.win and vim.api.nvim_win_is_valid(ghost_window.win) then
    vim.api.nvim_win_close(ghost_window.win, false)
    ghost_window.win = nil
    return true
  end
  return false
end

-- Toggle ghost window visibility
function M.toggle()
  if M.is_open() then
    M.close()
  else
    -- Create empty ghost window
    get_or_create_ghost_window()
  end
end

-- Set ghost window position
-- @param position string: "right", "left", "bottom", "top"
function M.set_position(position)
  local valid = {right=true, left=true, bottom=true, top=true}
  if not valid[position] then
    vim.notify("Invalid position: " .. position, vim.log.levels.ERROR)
    return false
  end

  -- Close existing window
  if M.is_open() then
    M.close()
  end

  ghost_window.position = position
  vim.notify("Ghost window position set to: " .. position, vim.log.levels.INFO)
  return true
end

-- Get current position
function M.get_position()
  return ghost_window.position
end

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Update ghost window state from config
  ghost_window.position = M.config.position or ghost_window.position
  ghost_window.width = M.config.width or ghost_window.width
  ghost_window.height = M.config.height or ghost_window.height
end

return M
