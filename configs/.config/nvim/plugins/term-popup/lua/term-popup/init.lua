local M = {}

-- Plugin state - now supports multiple terminals indexed by command
local terminals = {}
local default_terminal = {
  buf = nil,
  win = nil,
  current_mode = nil,
}

-- Track the last opened terminal
local last_opened_terminal = nil

-- Default configuration
M.config = {
  mode = "bottom",  -- Default: "bottom", "top", "right", "left", "float"

  -- Split dimensions
  split_height = 15,  -- For bottom/top splits (in lines)
  split_width = 80,   -- For right/left splits (in columns, or 0.0-1.0 for percentage)

  -- Float dimensions
  size = {
    width = 0.8,  -- 80% of screen width
    height = 0.8, -- 80% of screen height
  },
  border = "rounded",
  shell = nil, -- uses vim.o.shell by default

  -- Mode cycle order for toggle_mode()
  mode_cycle = {"bottom", "right", "float"},
}

-- Valid modes
local VALID_MODES = {
  bottom = true,
  top = true,
  right = true,
  left = true,
  float = true,
}

-- Get terminal state for a given command (or default)
local function get_terminal_state(command)
  if command then
    if not terminals[command] then
      terminals[command] = {
        buf = nil,
        win = nil,
        command = command,
        current_mode = nil,
        preferred_mode = nil,  -- Per-terminal mode preference
      }
    end
    return terminals[command]
  else
    return default_terminal
  end
end

-- Find which terminal state owns a buffer
local function find_terminal_by_buf(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return nil
  end

  -- Check default terminal
  if default_terminal.buf == buf then
    return default_terminal
  end

  -- Check command-specific terminals
  for _, state in pairs(terminals) do
    if state.buf == buf then
      return state
    end
  end

  return nil
end

-- Track last accessed terminal (updated by autocmd)
local last_accessed_terminal = nil

-- Close a specific terminal window
local function close_terminal_window(state)
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, false)
    state.win = nil
    state.current_mode = nil
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
        vim.fn.termopen(command)
      else
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
  state.current_mode = "float"

  -- Enter terminal mode
  vim.cmd('startinsert')
end

-- Create bottom split terminal window
local function create_bottom_split(command)
  local state = get_terminal_state(command)

  -- Create buffer if it doesn't exist or is invalid
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = vim.api.nvim_create_buf(false, true)

    -- Start terminal in the buffer
    vim.api.nvim_buf_call(state.buf, function()
      if command then
        vim.fn.termopen(command)
      else
        vim.fn.termopen(M.config.shell or vim.o.shell)
      end
    end)

    -- Set buffer options
    vim.api.nvim_buf_set_option(state.buf, 'filetype', 'terminal')

    -- Set buffer name for identification
    local buf_name = command and ("term://" .. command) or "term://default"
    vim.api.nvim_buf_set_name(state.buf, buf_name)
  end

  -- Create the split window at bottom
  vim.cmd('botright ' .. M.config.split_height .. 'split')
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)

  -- Set window options to prevent immersion breaking
  vim.api.nvim_win_set_option(state.win, 'winfixheight', true)
  vim.api.nvim_win_set_option(state.win, 'number', false)
  vim.api.nvim_win_set_option(state.win, 'relativenumber', false)
  vim.api.nvim_win_set_option(state.win, 'signcolumn', 'no')

  state.current_mode = "bottom"

  -- Enter terminal mode
  vim.cmd('startinsert')
end

-- Create top split terminal window
local function create_top_split(command)
  local state = get_terminal_state(command)

  -- Create buffer if it doesn't exist or is invalid
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = vim.api.nvim_create_buf(false, true)

    -- Start terminal in the buffer
    vim.api.nvim_buf_call(state.buf, function()
      if command then
        vim.fn.termopen(command)
      else
        vim.fn.termopen(M.config.shell or vim.o.shell)
      end
    end)

    -- Set buffer options
    vim.api.nvim_buf_set_option(state.buf, 'filetype', 'terminal')

    -- Set buffer name for identification
    local buf_name = command and ("term://" .. command) or "term://default"
    vim.api.nvim_buf_set_name(state.buf, buf_name)
  end

  -- Create the split window at top
  vim.cmd('topleft ' .. M.config.split_height .. 'split')
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)

  -- Set window options
  vim.api.nvim_win_set_option(state.win, 'winfixheight', true)
  vim.api.nvim_win_set_option(state.win, 'number', false)
  vim.api.nvim_win_set_option(state.win, 'relativenumber', false)
  vim.api.nvim_win_set_option(state.win, 'signcolumn', 'no')

  state.current_mode = "top"

  -- Enter terminal mode
  vim.cmd('startinsert')
end

-- Create right split terminal window
local function create_right_split(command)
  local state = get_terminal_state(command)

  -- Create buffer if it doesn't exist or is invalid
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = vim.api.nvim_create_buf(false, true)

    -- Start terminal in the buffer
    vim.api.nvim_buf_call(state.buf, function()
      if command then
        vim.fn.termopen(command)
      else
        vim.fn.termopen(M.config.shell or vim.o.shell)
      end
    end)

    -- Set buffer options
    vim.api.nvim_buf_set_option(state.buf, 'filetype', 'terminal')

    -- Set buffer name for identification
    local buf_name = command and ("term://" .. command) or "term://default"
    vim.api.nvim_buf_set_name(state.buf, buf_name)
  end

  -- Determine split width
  local width = M.config.split_width
  if type(width) == "number" and width > 0 and width < 1 then
    -- Percentage mode
    local total_width = vim.api.nvim_get_option_value("columns", {})
    width = math.ceil(total_width * width)
  end

  -- Create the split window at right
  vim.cmd('vertical botright ' .. width .. 'split')
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)

  -- Set window options
  vim.api.nvim_win_set_option(state.win, 'winfixwidth', true)
  vim.api.nvim_win_set_option(state.win, 'number', false)
  vim.api.nvim_win_set_option(state.win, 'relativenumber', false)
  vim.api.nvim_win_set_option(state.win, 'signcolumn', 'no')

  state.current_mode = "right"

  -- Enter terminal mode
  vim.cmd('startinsert')
end

-- Create left split terminal window
local function create_left_split(command)
  local state = get_terminal_state(command)

  -- Create buffer if it doesn't exist or is invalid
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = vim.api.nvim_create_buf(false, true)

    -- Start terminal in the buffer
    vim.api.nvim_buf_call(state.buf, function()
      if command then
        vim.fn.termopen(command)
      else
        vim.fn.termopen(M.config.shell or vim.o.shell)
      end
    end)

    -- Set buffer options
    vim.api.nvim_buf_set_option(state.buf, 'filetype', 'terminal')

    -- Set buffer name for identification
    local buf_name = command and ("term://" .. command) or "term://default"
    vim.api.nvim_buf_set_name(state.buf, buf_name)
  end

  -- Determine split width
  local width = M.config.split_width
  if type(width) == "number" and width > 0 and width < 1 then
    -- Percentage mode
    local total_width = vim.api.nvim_get_option_value("columns", {})
    width = math.ceil(total_width * width)
  end

  -- Create the split window at left
  vim.cmd('vertical topleft ' .. width .. 'split')
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)

  -- Set window options
  vim.api.nvim_win_set_option(state.win, 'winfixwidth', true)
  vim.api.nvim_win_set_option(state.win, 'number', false)
  vim.api.nvim_win_set_option(state.win, 'relativenumber', false)
  vim.api.nvim_win_set_option(state.win, 'signcolumn', 'no')

  state.current_mode = "left"

  -- Enter terminal mode
  vim.cmd('startinsert')
end

-- Create terminal window based on mode
local function create_window(command, mode)
  if mode == "float" then
    create_floating_window(command)
  elseif mode == "bottom" then
    create_bottom_split(command)
  elseif mode == "top" then
    create_top_split(command)
  elseif mode == "right" then
    create_right_split(command)
  elseif mode == "left" then
    create_left_split(command)
  else
    vim.notify("Invalid mode: " .. mode, vim.log.levels.ERROR)
  end
end

-- Unified toggle function
function M.toggle(command, mode_override)
  local state = get_terminal_state(command)

  -- Determine which mode to use:
  -- 1. Explicit override, 2. Terminal's preferred mode, 3. Global default
  local mode = mode_override or state.preferred_mode or M.config.mode

  -- Check if this terminal is currently open anywhere
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    -- It's open, close it
    close_terminal_window(state)
  else
    -- It's not open, open it in the specified mode
    -- Track this as the last opened terminal
    last_opened_terminal = state  -- Still track when opened, but autocmd will update based on access

    create_window(command, mode)
  end
end

-- Close any open terminal (focused or by command)
function M.close(command)
  if command then
    local state = get_terminal_state(command)
    close_terminal_window(state)
  else
    -- Close currently focused window if it's a terminal
    local current_win = vim.api.nvim_get_current_win()
    local current_buf = vim.api.nvim_win_get_buf(current_win)
    local buf_type = vim.api.nvim_buf_get_option(current_buf, 'buftype')

    if buf_type == 'terminal' then
      vim.api.nvim_win_close(current_win, false)
    end
  end
end

-- Set terminal mode
function M.set_mode(mode)
  if not VALID_MODES[mode] then
    vim.notify("Invalid mode: " .. mode .. ". Valid modes: bottom, top, right, left, float", vim.log.levels.ERROR)
    return
  end

  -- Use last accessed terminal if available, otherwise fall back to last opened
  local target_terminal = last_accessed_terminal or last_opened_terminal
  if not target_terminal then
    vim.notify("No terminal opened yet. Mode change is a no-op.", vim.log.levels.INFO)
    return
  end

  -- Check if the last terminal still exists
  if not last_opened_terminal.buf or not vim.api.nvim_buf_is_valid(last_opened_terminal.buf) then
    vim.notify("Last opened terminal no longer exists. Mode change is a no-op.", vim.log.levels.WARN)
    target_terminal = nil
    return
  end

  -- Check if the terminal is currently visible
  local was_open = last_opened_terminal.win and vim.api.nvim_win_is_valid(last_opened_terminal.win)

  if was_open then
    -- Close the current window
    close_terminal_window(target_terminal)

    -- Reopen in the new mode
    create_window(target_terminal.command, mode)

    -- Store this as the terminal's preferred mode
    target_terminal.preferred_mode = mode

    vim.notify("Terminal mode changed to: " .. mode, vim.log.levels.INFO)
  else
    -- Store the preference for when it's opened next
    target_terminal.preferred_mode = mode
    vim.notify("Terminal mode will be '" .. mode .. "' when opened next", vim.log.levels.INFO)
  end
end

-- Get current mode
function M.get_mode()
  return M.config.mode
end

-- Toggle between modes (cycles through mode_cycle)
function M.toggle_mode()
  local cycle = M.config.mode_cycle
  local current_mode = M.config.mode

  -- Find current mode in cycle
  local current_index = 1
  for i, mode in ipairs(cycle) do
    if mode == current_mode then
      current_index = i
      break
    end
  end

  -- Move to next mode in cycle
  local next_index = (current_index % #cycle) + 1
  local next_mode = cycle[next_index]

  M.set_mode(next_mode)
end

-- Execute command in command-specific terminal (create if doesn't exist)
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

function M.open(command, mode_override)
  local mode = mode_override or M.config.mode
  local state = get_terminal_state(command)

  -- Close if already open
  close_terminal_window(state)

  -- Open in specified mode
  create_window(command, mode)
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
  close_terminal_window(state)
end

-- Close all terminals
function M.close_all()
  -- Close default terminal
  close_terminal_window(default_terminal)

  -- Close all command-specific terminals
  for command, state in pairs(terminals) do
    close_terminal_window(state)
  end
end

-- Check if a terminal is open (any terminal)
function M.is_open()
  if default_terminal.win and vim.api.nvim_win_is_valid(default_terminal.win) then
    return true
  end

  for _, state in pairs(terminals) do
    if state.win and vim.api.nvim_win_is_valid(state.win) then
      return true
    end
  end

  return false
end

-- Check if command-specific terminal is open
function M.is_command_open(command)
  if not command then
    return default_terminal.win and vim.api.nvim_win_is_valid(default_terminal.win)
  end

  local state = get_terminal_state(command)
  return state.win and vim.api.nvim_win_is_valid(state.win)
end

-- Get which terminals are currently open
function M.get_open_terminals()
  local open_terminals = {}

  if default_terminal.win and vim.api.nvim_win_is_valid(default_terminal.win) then
    table.insert(open_terminals, {
      command = "default",
      mode = default_terminal.current_mode
    })
  end

  for command, state in pairs(terminals) do
    if state.win and vim.api.nvim_win_is_valid(state.win) then
      table.insert(open_terminals, {
        command = command,
        mode = state.current_mode
      })
    end
  end

  return open_terminals
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

  -- Set up autocmd to track last accessed terminal
  local group = vim.api.nvim_create_augroup("TermPopupTracking", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function(ev)
      local buf = ev.buf
      local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')

      -- Only track if it's a terminal buffer
      if buftype == 'terminal' then
        local state = find_terminal_by_buf(buf)
        if state then
          last_accessed_terminal = state
        end
      end
    end,
  })

  -- Validate mode
  if not VALID_MODES[M.config.mode] then
    vim.notify("Invalid default mode: " .. M.config.mode .. ". Falling back to 'bottom'", vim.log.levels.WARN)
    M.config.mode = "bottom"
  end

  -- Create user command for mode switching
  vim.api.nvim_create_user_command('PopupTerminalMode', function(cmd_opts)
    if cmd_opts.args == "" then
      -- No args: show current mode
      print("Global terminal mode: " .. M.get_mode())
    else
      -- Set the mode
      M.set_mode(cmd_opts.args)
    end
  end, {
    nargs = '?',
    complete = function()
      return {"bottom", "top", "right", "left", "float"}
    end,
    desc = "Get or set global popup terminal mode"
  })
end

return M
