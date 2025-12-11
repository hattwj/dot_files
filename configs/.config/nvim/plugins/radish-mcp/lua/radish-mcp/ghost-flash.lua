-- Ghost Flash - Visual line highlighting for AI edits
local M = {}

-- Default configuration
M.config = {
  duration_ms = 2000,
  highlight = {
    -- bg = "#2a4060",  -- Darker blue (subtle and visible)
    -- Alternative colors:
    bg = "#2d5f2d",  -- Darker green
    -- bg = "#6b5a3d",  -- Darker gold/amber
    -- bg = "#5a2d3f",  -- Darker purple
    bold = false,
  }
}

-- Setup function to configure colors
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Create highlight group
  vim.api.nvim_set_hl(0, "GhostFlash", M.config.highlight)
end

-- Flash highlight lines in a buffer
-- @param bufnr: buffer number (or 0 for current)
-- @param start_line: starting line (1-indexed)
-- @param end_line: ending line (1-indexed, inclusive)
-- @param duration_ms: how long to show highlight (optional, uses config default)
function M.flash_lines(bufnr, start_line, end_line, duration_ms)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  duration_ms = duration_ms or M.config.duration_ms

  -- Validate buffer
  if not vim.api.nvim_buf_is_valid(bufnr) then
    vim.notify("Ghost Flash: Invalid buffer", vim.log.levels.ERROR)
    return
  end

  -- Validate line range
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if start_line < 1 or end_line > line_count then
    vim.notify(string.format("Ghost Flash: Line range %d-%d out of bounds (1-%d)",
      start_line, end_line, line_count), vim.log.levels.WARN)
    return
  end

  -- Create namespace for this flash
  local ns = vim.api.nvim_create_namespace("ghost_flash")

  -- Apply extmarks to each line (convert to 0-indexed)
  for line = start_line - 1, end_line - 1 do
    vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, {
      line_hl_group = "GhostFlash"
    })
  end

  -- Schedule cleanup
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    end
  end, duration_ms)
end


-- Flash a file by path (useful for external edits)
-- @param filepath: absolute or relative path to file
-- @param start_line: starting line (1-indexed)
-- @param end_line: ending line (1-indexed)
-- @param duration_ms: optional duration
function M.flash_file(filepath, start_line, end_line, duration_ms)
  local bufnr = vim.fn.bufnr(filepath)

  if bufnr == -1 then
    vim.notify("Ghost Flash: Buffer not loaded for " .. filepath, vim.log.levels.WARN)
    return
  end

  M.flash_lines(bufnr, start_line, end_line, duration_ms)

  -- Optional: Switch to window showing this buffer
  local wins = vim.fn.win_findbuf(bufnr)
  if #wins > 0 then
    vim.api.nvim_set_current_win(wins[1])
    -- Center on the change
    vim.api.nvim_win_set_cursor(wins[1], {start_line, 0})
    vim.cmd("normal! zz")
  end
end

-- Initialize with default config
M.setup()

return M
