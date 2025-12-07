-- Ghost Display - Visual feedback for file changes
local window_manager = require("radish-mcp.window-manager")
local M = {}

-- Namespace for highlights
M.ns_id = vim.api.nvim_create_namespace("radish_ghost")

-- Configuration
M.config = {
  highlight_duration = 2000,
  highlight_color = "#4a4a00",
  fade_steps = 10,
}

-- Set up highlight groups
local function setup_highlights()
  vim.api.nvim_set_hl(0, "RadishGhostChange", {
    bg = M.config.highlight_color,
  })
end

setup_highlights()

-- Open file in editor using shared window manager
function M.open_file(filepath)
  vim.schedule(function()
    local full_path = vim.fn.expand(filepath)

    -- Use window manager to avoid terminal stomping
    window_manager.get_file_window()

    -- Open file
    vim.cmd("edit " .. vim.fn.fnameescape(full_path))
  end)
end

-- Show change with flash highlight
function M.show_change(filepath, event)
  vim.schedule(function()
    local full_path = vim.fn.expand(filepath)
    local bufnr = vim.fn.bufnr(full_path)

    -- Buffer not loaded
    if bufnr == -1 then
      return
    end

    -- Reload buffer from disk
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("checktime")
    end)

    -- Get all lines in buffer
    local line_count = vim.api.nvim_buf_line_count(bufnr)

    -- Highlight all lines (we don't have old content to diff)
    for i = 0, line_count - 1 do
      vim.api.nvim_buf_add_highlight(bufnr, M.ns_id, "RadishGhostChange", i, 0, -1)
    end

    -- Fade out after duration
    local fade_timer = vim.loop.new_timer()
    fade_timer:start(M.config.highlight_duration, 0, vim.schedule_wrap(function()
      -- Clear highlights
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_clear_namespace(bufnr, M.ns_id, 0, -1)
      end
      fade_timer:close()
    end))

    -- Show notification
    vim.notify(
      string.format("✓ %s updated", vim.fn.fnamemodify(full_path, ":t")),
      vim.log.levels.INFO
    )
  end)
end

-- Configure ghost display
function M.setup(config)
  M.config = vim.tbl_deep_extend("force", M.config, config or {})
  setup_highlights()
end

return M
