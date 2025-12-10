local M = {}

-- Load window manager for layout operations
local wm = require('window-manager')

-- Plugin state - now supports multiple terminals indexed by command
local terminals = {}

-- Track ALL terminal buffers we create (for deterministic cleanup)
-- Store globally to survive module reloads
_G._term_popup_created_buffers = _G._term_popup_created_buffers or {}
local created_buffers = _G._term_popup_created_buffers
local default_terminal = {
  buf = nil,
  win = nil,
  current_mode = nil,
  preferred_mode = nil,
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

-- Detect window position type (float, bottom, top, left, right)
local function detect_window_position(win)
  if not win or not vim.api.nvim_win_is_valid(win) then
    return nil
  end

  -- Check if it's a floating window
  local config = vim.api.nvim_win_get_config(win)
  if config.relative and config.relative ~= "" then
    return "float"
  end

  -- It's a split window - determine which type
  local win_height = vim.api.nvim_win_get_height(win)
  local win_width = vim.api.nvim_win_get_width(win)
  local screen_height = vim.api.nvim_get_option_value("lines", {})
  local screen_width = vim.api.nvim_get_option_value("columns", {})

  -- Get window position
  local win_pos = vim.api.nvim_win_get_position(win)
  local row = win_pos[1]
  local col = win_pos[2]

  -- Check if it spans full width (likely top or bottom)
  local is_full_width = win_width >= (screen_width - 5)  -- Allow some margin

  -- Check if it spans full height (likely left or right)
  local is_full_height = win_height >= (screen_height - 5)

  if is_full_width then
    -- It's either top or bottom
    if row == 0 then
      return "top"
    else
      return "bottom"
    end
  elseif is_full_height then
    -- It's either left or right
    if col == 0 then
      return "left"
    else
      return "right"
    end
  end

  -- Default to current_mode if we can't determine
  return nil
end

-- Check if terminal job is still alive
local function is_terminal_alive(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  -- Get the terminal job ID
  local ok, chan_id = pcall(vim.api.nvim_buf_get_var, buf, 'terminal_job_id')
  if not ok or not chan_id then
    return false
  end

  -- Check if job is running (jobwait with 0 timeout returns -1 if running)
  local result = vim.fn.jobwait({chan_id}, 0)[1]
  return result == -1  -- -1 means still running, >=0 means exited
end

-- Clean up terminal state when process exits
local function cleanup_terminal(state)
  -- Close window if open
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, false)
  end
  -- Delete the buffer to force complete cleanup
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_buf_delete(state.buf, { force = true })
  end
  -- Remove from tracking
  created_buffers[state.buf] = nil
  -- Invalidate references
  state.buf = nil
  state.win = nil
end

-- Clean up orphaned dead terminal buffers not tracked by any state
local function cleanup_orphaned_terminals()
  -- Iterate through all buffers we've created
  for buf, _ in pairs(created_buffers) do
    if vim.api.nvim_buf_is_valid(buf) then
      -- Check if terminal is dead
      if not is_terminal_alive(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
        created_buffers[buf] = nil
      end
    else
      -- Buffer is invalid, remove from tracking
      created_buffers[buf] = nil
    end
  end
end

-- Close a specific terminal window
local function close_terminal_window(state)
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    -- Detect and remember the window position before closing
    local detected_position = detect_window_position(state.win)
    if detected_position then
      state.preferred_mode = detected_position
      state.current_mode = detected_position
    end

    vim.api.nvim_win_close(state.win, false)
    state.win = nil
  end
end

-- Helper function to ensure terminal buffer exists and is valid
-- Creates buffer if needed, starts terminal job, and tracks it
local function ensure_terminal_buffer(state, command)
  -- Check if buffer already exists and is alive
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) and is_terminal_alive(state.buf) then
    return  -- Buffer already exists and terminal is alive
  end

  -- Terminal is dead or doesn't exist, clean up completely
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_buf_delete(state.buf, { force = true })
  end
  state.buf = nil

  -- Create new buffer
  state.buf = vim.api.nvim_create_buf(false, true)

  -- Track this buffer
  created_buffers[state.buf] = true

  -- Set buffer options
  vim.api.nvim_set_option_value('filetype', 'terminal', { buf = state.buf })

  -- Start terminal in the buffer
  vim.api.nvim_buf_call(state.buf, function()
    if command then
      vim.fn.jobstart(command, {
        term = true,
        on_exit = function()
          vim.schedule(function()
            cleanup_terminal(state)
          end)
        end
      })
    else
      vim.fn.jobstart(M.config.shell or vim.o.shell, {
        term = true,
        on_exit = function() vim.schedule(function() cleanup_terminal(state) end) end
      })
    end
  end)
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

  ensure_terminal_buffer(state, command)

  -- Create the floating window
  state.win = vim.api.nvim_open_win(state.buf, true, opts)
  state.current_mode = "float"

  -- Enter terminal mode
  vim.cmd('startinsert')
end

-- Generic split terminal creation
-- @param command: command to run (nil for shell)
-- @param mode: "bottom", "top", "right", "left"
-- @param split_cmd: vim command to create split (e.g., "botright 15split")
-- @param fix_option: "winfixheight" or "winfixwidth"
local function create_split_terminal(command, mode, split_cmd, fix_option)
  local state = get_terminal_state(command)

  ensure_terminal_buffer(state, command)

  -- Create the split window
  vim.cmd(split_cmd)
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)

  -- Set window options
  vim.api.nvim_set_option_value(fix_option, true, {win = state.win})
  vim.api.nvim_set_option_value('number', false, {win = state.win})
  vim.api.nvim_set_option_value('relativenumber', false, {win = state.win})
  vim.api.nvim_set_option_value('signcolumn', 'no', {win = state.win})

  state.current_mode = mode

  -- Enter terminal mode
  vim.cmd('startinsert')
end

-- Create bottom split terminal window
local function create_bottom_split(command)
  local split_cmd = 'botright ' .. M.config.split_height .. 'split'
  create_split_terminal(command, "bottom", split_cmd, 'winfixheight')
end

-- Create top split terminal window
local function create_top_split(command)
  local split_cmd = 'topleft ' .. M.config.split_height .. 'split'
  create_split_terminal(command, "top", split_cmd, 'winfixheight')
end

-- Create right split terminal window
local function create_right_split(command)
  -- Determine split width
  local width = M.config.split_width
  if type(width) == "number" and width > 0 and width < 1 then
    -- Percentage mode
    local total_width = vim.api.nvim_get_option_value("columns", {})
    width = math.ceil(total_width * width)
  end

  local split_cmd = 'vertical botright ' .. width .. 'split'
  create_split_terminal(command, "right", split_cmd, 'winfixwidth')
end

-- Create left split terminal window
local function create_left_split(command)
  -- Determine split width
  local width = M.config.split_width
  if type(width) == "number" and width > 0 and width < 1 then
    -- Percentage mode
    local total_width = vim.api.nvim_get_option_value("columns", {})
    width = math.ceil(total_width * width)
  end

  local split_cmd = 'vertical topleft ' .. width .. 'split'
  create_split_terminal(command, "left", split_cmd, 'winfixwidth')
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
-- Priority: 1. preferred_mode (user moved), 2. keymap_default (caller suggests), 3. global config
function M.toggle(command, keymap_default)
  local state = get_terminal_state(command)

  -- Determine which mode to use (priority order):
  -- 1. Terminal's preferred mode (user moved it)
  -- 2. Keymap default (suggested by the specific keymap)
  -- 3. Global config default
  local mode = state.preferred_mode or keymap_default or M.config.mode


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
    local buf_type = vim.api.nvim_get_option_value('buftype', { buf = current_buf })

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

function M.open(command, keymap_default)
  local mode = keymap_default or M.config.mode
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
  -- Register callback with window manager to track position changes
  wm.on_position_change(function(win, position)

    -- Find terminal by buffer (not by window, since window ID changed!)
    local buf = vim.api.nvim_win_get_buf(win)
    local state = find_terminal_by_buf(buf)

    if state then
      state.preferred_mode = position
      state.current_mode = position
      state.win = win  -- Update to new window ID!
    else
    end

    -- Old logic (kept for backwards compat, but shouldn't match since window ID changed)
    -- Find which terminal owns this window
    if default_terminal.win == win then
      default_terminal.preferred_mode = position
      default_terminal.current_mode = position
    else
      for _, state in pairs(terminals) do
        if state.win == win then
          state.preferred_mode = position
          state.current_mode = position
        end
      end
    end
  end)

  -- Merge user config with defaults
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Clean up any orphaned terminal buffers from previous sessions
  cleanup_orphaned_terminals()

  -- Set up autocmd to track last accessed terminal
  local group = vim.api.nvim_create_augroup("TermPopupTracking", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function(ev)
      local buf = ev.buf
      local buftype = vim.api.nvim_get_option_value('buftype', { buf = buf })

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
