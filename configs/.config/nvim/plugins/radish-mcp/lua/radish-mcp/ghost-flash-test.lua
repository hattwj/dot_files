-- Ghost Flash Test Module
-- Tests visual highlighting of changed lines
-- Step 1 of Ghost Change Flash implementation

local M = {}

-- Configuration
M.config = {
  flash_duration_ms = 2000,  -- How long to show highlight
  flash_color = "#3d59a1",   -- Blue by default
  fade_steps = 0,            -- 0 = instant removal, >0 = fade effect
}

-- Namespace for highlights
local ns_id = vim.api.nvim_create_namespace("ghost_flash_test")

-- Initialize highlight group
local function setup_highlights()
  vim.api.nvim_set_hl(0, "GhostFlash", {
    bg = M.config.flash_color,
    bold = true
  })
end

-- Flash highlight a range of lines
-- @param bufnr: buffer number (0 for current)
-- @param start_line: 1-indexed start line
-- @param end_line: 1-indexed end line
-- @param duration_ms: how long to show highlight (optional, uses config default)
function M.flash_lines(bufnr, start_line, end_line, duration_ms)
  bufnr = bufnr or 0
  if bufnr == 0 then
    bufnr = vim.api.nvim_get_current_buf()
  end

  duration_ms = duration_ms or M.config.flash_duration_ms

  -- Ensure highlight group exists
  setup_highlights()

  -- Apply highlight to each line in range
  for line = start_line - 1, end_line - 1 do  -- Convert to 0-indexed
    if line >= 0 and line < vim.api.nvim_buf_line_count(bufnr) then
      vim.api.nvim_buf_add_highlight(bufnr, ns_id, "GhostFlash", line, 0, -1)
    end
  end

  -- Remove highlight after duration
  vim.defer_fn(function()
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
  end, duration_ms)

  return true
end

-- Flash highlight the current line
function M.flash_current_line()
  local line = vim.fn.line(".")
  M.flash_lines(0, line, line)
  vim.notify(string.format("Ghost: Flashing line %d for %dms",
    line, M.config.flash_duration_ms), vim.log.levels.INFO)
end

-- Flash highlight a visual selection
function M.flash_visual_selection()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  M.flash_lines(0, start_line, end_line)
  vim.notify(string.format("Ghost: Flashing lines %d-%d for %dms",
    start_line, end_line, M.config.flash_duration_ms), vim.log.levels.INFO)
end

-- Setup function to create commands
function M.setup(opts)
  -- Merge config
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Initialize highlights
  setup_highlights()

  -- Create test command for current line
  vim.api.nvim_create_user_command("GhostTestFlash", function()
    M.flash_current_line()
  end, {
    desc = "Test ghost flash highlight on current line"
  })

  -- Create test command with range support
  vim.api.nvim_create_user_command("GhostTestFlashRange", function(cmd_opts)
    local start_line = cmd_opts.line1
    local end_line = cmd_opts.line2

    M.flash_lines(0, start_line, end_line)
    vim.notify(string.format("Ghost: Flashing lines %d-%d for %dms",
      start_line, end_line, M.config.flash_duration_ms), vim.log.levels.INFO)
  end, {
    range = true,
    desc = "Test ghost flash highlight on line range"
  })

  -- Create test command with custom duration
  vim.api.nvim_create_user_command("GhostTestFlashCustom", function(cmd_opts)
    local duration = tonumber(cmd_opts.args) or M.config.flash_duration_ms
    local line = vim.fn.line(".")

    M.flash_lines(0, line, line, duration)
    vim.notify(string.format("Ghost: Flashing line %d for %dms",
      line, duration), vim.log.levels.INFO)
  end, {
    nargs = "?",
    desc = "Test ghost flash with custom duration (ms)"
  })

  vim.notify("Ghost Flash Test: Commands loaded (:GhostTestFlash, :GhostTestFlashRange, :GhostTestFlashCustom)",
    vim.log.levels.INFO)
end

return M
