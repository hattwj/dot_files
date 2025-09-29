local M = {}

-- Plugin state - now supports multiple terminals indexed by command
local terminals = {}
local default_terminal = {
  buf = nil,
  win = nil,
}

-- Track which terminal is currently open
local current_open_terminal = nil

-- Default configuration
M.config = {
  size = {
    width = 0.8,  -- 80% of screen width
    height = 0.8, -- 80% of screen height
  },
  border = "rounded",
  shell = nil, -- uses vim.o.shell by default
}

-- Get terminal state for a given command (or default)
local function get_terminal_state(command)
  if command then
    if not terminals[command] then
      terminals[command] = {
        buf = nil,
        win = nil,
        command = command,
      }
    end
    return terminals[command]
  else
    return default_terminal
  end
end

-- Close any currently open terminal
local function close_current_terminal()
  if current_open_terminal then
    local state = get_terminal_state(current_open_terminal)
    if state.win and vim.api.nvim_win_is_valid(state.win) then
      vim.api.nvim_win_close(state.win, false)
      state.win = nil
    end
    current_open_terminal = nil
  elseif default_terminal.win and vim.api.nvim_win_is_valid(default_terminal.win) then
    vim.api.nvim_win_close(default_terminal.win, false)
    default_terminal.win = nil
    current_open_terminal = nil
  end
end

-- Create floating terminal window
local function create_floating_window(command)
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

  local state = get_terminal_state(command)

  -- Create buffer if it doesn't exist or is invalid
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = vim.api.nvim_create_buf(false, true)

    -- Start terminal in the buffer
    vim.api.nvim_buf_call(state.buf, function()
      if command then
        -- For command-specific terminals, start with the command
        vim.fn.termopen(command)
      else
        -- For default terminal, use configured shell
        vim.fn.termopen(M.config.shell or vim.o.shell)
      end
    end)

    -- Set buffer options
    vim.api.nvim_buf_set_option(state.buf, 'filetype', 'terminal')

    -- Set buffer name for identification
    local buf_name = command and ("term://" .. command) or "term://default"
    vim.api.nvim_buf_set_name(state.buf, buf_name)
  end

  -- Create the floating window
  state.win = vim.api.nvim_open_win(state.buf, true, opts)

  -- Update current open terminal tracker
  current_open_terminal = command

  -- Enter terminal mode
  vim.cmd('startinsert')
end

-- Unified toggle function - this is the main function now
function M.toggle(command)
  -- Determine if the requested terminal is currently open
  local requested_state = get_terminal_state(command)
  local is_requested_open = requested_state.win and vim.api.nvim_win_is_valid(requested_state.win)

  if is_requested_open then
    -- If the requested terminal is already open, close it
    close_current_terminal()
  else
    -- Close any other open terminal first
    close_current_terminal()
    -- Then open the requested terminal
    create_floating_window(command)
  end
end

-- Close any open terminal (unified close)
function M.close()
  close_current_terminal()
end

-- Execute command in command-specific terminal (create if doesn't exist)
-- This is now just an alias for toggle for consistency
function M.exec_command(command)
  if not command then
    error("Command is required for exec_command")
  end
  M.toggle(command)
end

-- Legacy functions for backward compatibility
function M.toggle_command(command)
  M.toggle(command)
end

function M.open(command)
  -- Close any open terminal first
  close_current_terminal()
  create_floating_window(command)
end

function M.open_command(command)
  if not command then
    error("Command is required for open_command")
  end
  M.open(command)
end

function M.close_command(command)
  if not command then
    error("Command is required for close_command")
  end

  local state = get_terminal_state(command)
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, false)
    state.win = nil
    if current_open_terminal == command then
      current_open_terminal = nil
    end
  end
end

-- Close all terminals
function M.close_all()
  close_current_terminal()
  -- Also close any orphaned terminals
  for command, state in pairs(terminals) do
    if state.win and vim.api.nvim_win_is_valid(state.win) then
      vim.api.nvim_win_close(state.win, false)
      state.win = nil
    end
  end
end

-- Check if a terminal is open (any terminal)
function M.is_open()
  return current_open_terminal ~= nil or
         (default_terminal.win and vim.api.nvim_win_is_valid(default_terminal.win))
end

-- Check if command-specific terminal is open
function M.is_command_open(command)
  if not command then
    return default_terminal.win and vim.api.nvim_win_is_valid(default_terminal.win)
  end

  local state = get_terminal_state(command)
  return state.win and vim.api.nvim_win_is_valid(state.win)
end

-- Get which terminal is currently open
function M.get_current_terminal()
  return current_open_terminal
end

-- Check if command-specific terminal exists (buffer created)
function M.command_exists(command)
  if not command then
    return default_terminal.buf and vim.api.nvim_buf_is_valid(default_terminal.buf)
  end

  local state = terminals[command]
  return state and state.buf and vim.api.nvim_buf_is_valid(state.buf)
end

-- Get terminal buffer
function M.get_buf(command)
  local state = get_terminal_state(command)
  return state.buf
end

-- Legacy function for backward compatibility
function M.get_command_buf(command)
  return M.get_buf(command)
end

-- List all existing command terminals
function M.list_commands()
  local commands = {}
  for command, state in pairs(terminals) do
    if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
      table.insert(commands, command)
    end
  end
  if default_terminal.buf and vim.api.nvim_buf_is_valid(default_terminal.buf) then
    table.insert(commands, "default")
  end
  return commands
end

-- Setup function for plugin configuration
function M.setup(opts)
  -- Merge user config with defaults
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
