-- Generic window manager for moving any window to different positions
-- Supports: float, bottom, top, right, left

local M = {}

-- Default configuration
M.config = {
  split_height = 15,  -- For bottom/top splits (in lines)
  split_width = 80,   -- For right/left splits (in columns, or 0.0-1.0 for percentage)

  float = {
    width = 0.8,  -- 80% of screen width
    height = 0.8, -- 80% of screen height
    border = "rounded",
  },
}

-- Callbacks to notify when window position changes
local position_change_callbacks = {}

-- Register a callback to be notified when a window moves
function M.on_position_change(callback)
  table.insert(position_change_callbacks, callback)
end

-- Notify all callbacks about position change
local function notify_position_change(win, position)
  for _, callback in ipairs(position_change_callbacks) do
    callback(win, position)
  end
end

-- Valid positions
local VALID_POSITIONS = {
  bottom = true,
  top = true,
  right = true,
  left = true,
  float = true,
}

-- Check if buffer can be moved (exclude special buffers)
local function can_move_buffer(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return false, "Invalid buffer"
  end

  local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
  local filetype = vim.api.nvim_buf_get_option(buf, 'filetype')

  -- Don't move special buffers
  local unmovable_buftypes = {
    prompt = true,
    nofile = true,  -- Dashboard, help, etc.
  }

  local unmovable_filetypes = {
    dashboard = true,
    alpha = true,
    starter = true,
  }

  if unmovable_buftypes[buftype] then
    return false, "Cannot move buffer of type: " .. buftype
  end

  if unmovable_filetypes[filetype] then
    return false, "Cannot move " .. filetype .. " buffer"
  end

  return true, nil
end

-- Move current window to float position
function M.move_to_float(win)
  win = win or vim.api.nvim_get_current_win()

  if not vim.api.nvim_win_is_valid(win) then
    vim.notify("Invalid window", vim.log.levels.ERROR)
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)

  -- Check if buffer can be moved
  local ok, err = can_move_buffer(buf)
  if not ok then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  local width = vim.api.nvim_get_option_value("columns", {})
  local height = vim.api.nvim_get_option_value("lines", {})

  local win_height = math.ceil(height * M.config.float.height - 4)
  local win_width = math.ceil(width * M.config.float.width)

  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    border = M.config.float.border
  }

  -- Close old window
  vim.api.nvim_win_close(win, false)

  -- Create new floating window
  local new_win = vim.api.nvim_open_win(buf, true, opts)

  -- Notify callbacks
  notify_position_change(new_win, "float")

  return new_win
end

-- Move current window to bottom split
function M.move_to_bottom(win)
  win = win or vim.api.nvim_get_current_win()

  if not vim.api.nvim_win_is_valid(win) then
    vim.notify("Invalid window", vim.log.levels.ERROR)
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)

  -- Check if buffer can be moved
  local ok, err = can_move_buffer(buf)
  if not ok then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  -- Close old window
  vim.api.nvim_win_close(win, false)

  -- Create bottom split
  vim.cmd('botright ' .. M.config.split_height .. 'split')
  local new_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(new_win, buf)

  -- Set window options
  vim.api.nvim_win_set_option(new_win, 'winfixheight', true)

  -- Notify callbacks
  notify_position_change(new_win, "bottom")

  return new_win
end

-- Move current window to top split
function M.move_to_top(win)
  win = win or vim.api.nvim_get_current_win()

  if not vim.api.nvim_win_is_valid(win) then
    vim.notify("Invalid window", vim.log.levels.ERROR)
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)

  -- Check if buffer can be moved
  local ok, err = can_move_buffer(buf)
  if not ok then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  -- Close old window
  vim.api.nvim_win_close(win, false)

  -- Create top split
  vim.cmd('topleft ' .. M.config.split_height .. 'split')
  local new_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(new_win, buf)

  -- Set window options
  vim.api.nvim_win_set_option(new_win, 'winfixheight', true)

  -- Notify callbacks
  notify_position_change(new_win, "top")

  return new_win
end

-- Move current window to right split
function M.move_to_right(win)
  win = win or vim.api.nvim_get_current_win()

  if not vim.api.nvim_win_is_valid(win) then
    vim.notify("Invalid window", vim.log.levels.ERROR)
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)

  -- Check if buffer can be moved
  local ok, err = can_move_buffer(buf)
  if not ok then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  -- Determine split width
  local width = M.config.split_width
  if type(width) == "number" and width > 0 and width < 1 then
    -- Percentage mode
    local total_width = vim.api.nvim_get_option_value("columns", {})
    width = math.ceil(total_width * width)
  end

  -- Close old window
  vim.api.nvim_win_close(win, false)

  -- Create right split
  vim.cmd('vertical botright ' .. width .. 'split')
  local new_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(new_win, buf)

  -- Set window options
  vim.api.nvim_win_set_option(new_win, 'winfixwidth', true)

  -- Notify callbacks
  notify_position_change(new_win, "right")

  return new_win
end

-- Move current window to left split
function M.move_to_left(win)
  win = win or vim.api.nvim_get_current_win()

  if not vim.api.nvim_win_is_valid(win) then
    vim.notify("Invalid window", vim.log.levels.ERROR)
    return
  end

  local buf = vim.api.nvim_win_get_buf(win)

  -- Check if buffer can be moved
  local ok, err = can_move_buffer(buf)
  if not ok then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  -- Determine split width
  local width = M.config.split_width
  if type(width) == "number" and width > 0 and width < 1 then
    -- Percentage mode
    local total_width = vim.api.nvim_get_option_value("columns", {})
    width = math.ceil(total_width * width)
  end

  -- Close old window
  vim.api.nvim_win_close(win, false)

  -- Create left split
  vim.cmd('vertical topleft ' .. width .. 'split')
  local new_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(new_win, buf)

  -- Set window options
  vim.api.nvim_win_set_option(new_win, 'winfixwidth', true)

  -- Notify callbacks
  notify_position_change(new_win, "left")

  return new_win
end

-- Generic move function
function M.move_to(position, win)
  if not VALID_POSITIONS[position] then
    vim.notify("Invalid position: " .. position .. ". Valid: bottom, top, right, left, float", vim.log.levels.ERROR)
    return
  end

  if position == "float" then
    return M.move_to_float(win)
  elseif position == "bottom" then
    return M.move_to_bottom(win)
  elseif position == "top" then
    return M.move_to_top(win)
  elseif position == "right" then
    return M.move_to_right(win)
  elseif position == "left" then
    return M.move_to_left(win)
  end
end

-- Setup keymaps
function M.setup_keymaps(opts)
  opts = opts or {}
  local prefix = opts.prefix or "<leader>w"

  -- Letter keymaps
  vim.keymap.set('n', prefix .. 'f', function() M.move_to_float() end, { desc = "Move window to float" })
  vim.keymap.set('n', prefix .. 'b', function() M.move_to_bottom() end, { desc = "Move window to bottom" })
  vim.keymap.set('n', prefix .. 't', function() M.move_to_top() end, { desc = "Move window to top" })
  vim.keymap.set('n', prefix .. 'r', function() M.move_to_right() end, { desc = "Move window to right" })
  vim.keymap.set('n', prefix .. 'l', function() M.move_to_left() end, { desc = "Move window to left" })
end

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Setup keymaps if requested
  if opts and opts.keymaps then
    M.setup_keymaps(opts.keymaps)
  end

  -- Create user command
  vim.api.nvim_create_user_command('WinMove', function(cmd_opts)
    M.move_to(cmd_opts.args)
  end, {
    nargs = 1,
    complete = function()
      return {"bottom", "top", "right", "left", "float"}
    end,
    desc = "Move current window to position"
  })
end

return M
