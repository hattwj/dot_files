local M = {}

-- Plugin state
local state = {
  buf = nil,
  win = nil,
}

-- Default configuration
M.config = {
  size = {
    width = 0.8,  -- 80% of screen width
    height = 0.8, -- 80% of screen height
  },
  border = "rounded",
  shell = nil, -- uses vim.o.shell by default
  keymaps = {
    toggle = "<leader><Esc>",
  }
}

-- Create floating terminal window
local function create_floating_window()
  local width = vim.api.nvim_get_option_value("columns", {})
  local height = vim.api.nvim_get_option_value("lines", {})

  local win_height = math.ceil(height * M.config.size.height - 4)
  local win_width = math.ceil(width * M.config.size.width)

  local row = math.ceil((height - win_height) / 2 - 1)
  local col = math.ceil((width - win_width) / 2)

  local opts = {
    style = "minimal",
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    border = M.config.border
  }

  -- Create buffer if it doesn't exist or is invalid
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = vim.api.nvim_create_buf(false, true)

    -- Start terminal in the buffer
    vim.api.nvim_buf_call(state.buf, function()
      vim.fn.termopen(M.config.shell or vim.o.shell)
    end)

    -- Set buffer options
    vim.api.nvim_buf_set_option(state.buf, 'filetype', 'terminal')
  end

  -- Create the floating window
  state.win = vim.api.nvim_open_win(state.buf, true, opts)

  -- Set up terminal mode keybinding for this specific buffer
  vim.keymap.set('t', '<Esc><Esc>', function()
    M.close()
  end, {
    buffer = state.buf,
    noremap = true,
    silent = true,
    desc = "Close term-popup from terminal mode"
  })

  -- Enter terminal mode
  vim.cmd('startinsert')
end

-- Toggle terminal visibility
function M.toggle()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    M.close()
  else
    M.open()
  end
end

-- Open terminal
function M.open()
  if not (state.win and vim.api.nvim_win_is_valid(state.win)) then
    create_floating_window()
  end
end

-- Close terminal
function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, false)
    state.win = nil
  end
end

-- Check if terminal is open
function M.is_open()
  return state.win and vim.api.nvim_win_is_valid(state.win)
end

-- Get terminal buffer
function M.get_buf()
  return state.buf
end

-- Setup function for plugin configuration
function M.setup(opts)
  -- Merge user config with defaults
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  -- Note: Keymaps are now handled by LazyVim plugin spec
end

return M
