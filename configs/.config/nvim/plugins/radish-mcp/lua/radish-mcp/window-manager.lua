-- Shared window management utilities
-- Ensures terminal windows are never stomped on
local M = {}

-- Find or create a non-terminal window for opening files
-- Returns: bufnr of the window to use, or nil on error
function M.get_file_window()
  local current_buf = vim.api.nvim_get_current_buf()
  local current_buftype = vim.api.nvim_get_option_value("buftype", { buf = current_buf })

  -- If we're not in a terminal, use current window
  if current_buftype ~= "terminal" then
    return vim.api.nvim_get_current_win()
  end

  -- We're in a terminal - find or create a normal window
  local windows = vim.api.nvim_list_wins()

  -- Try to find an existing normal window
  for _, win in ipairs(windows) do
    local win_buf = vim.api.nvim_win_get_buf(win)
    local win_buftype = vim.api.nvim_get_option_value("buftype", { buf = win_buf })

    if win_buftype == "" then
      vim.api.nvim_set_current_win(win)
      return win
    end
  end

  -- No normal window found - create a smart split
  M.create_smart_split()
  return vim.api.nvim_get_current_win()
end

-- Create a split on the opposite side of the terminal
function M.create_smart_split()
  local current_win = vim.api.nvim_get_current_win()
  local current_pos = vim.api.nvim_win_get_position(current_win)
  local windows = vim.api.nvim_list_wins()

  local has_left = false
  local has_right = false
  local has_top = false
  local has_bottom = false

  for _, win in ipairs(windows) do
    if win ~= current_win then
      local pos = vim.api.nvim_win_get_position(win)

      if pos[2] < current_pos[2] then
        has_left = true
      elseif pos[2] > current_pos[2] then
        has_right = true
      end

      if pos[1] < current_pos[1] then
        has_top = true
      elseif pos[1] > current_pos[1] then
        has_bottom = true
      end
    end
  end

  -- Decide split direction
  if has_left and not has_right then
    vim.cmd("leftabove vsplit")
  elseif has_right and not has_left then
    vim.cmd("rightbelow vsplit")
  elseif has_top and not has_bottom then
    vim.cmd("leftabove split")
  elseif has_bottom and not has_top then
    vim.cmd("rightbelow split")
  elseif current_pos[2] == 0 then
    vim.cmd("rightbelow vsplit")
  else
    vim.cmd("leftabove vsplit")
  end
end

return M
