-- Ghost Flash Orchestrator - Combines snapshot, watch, diff, and flash
local M = {}

-- Debug logging flag
M.debug = true

-- Load modules
local flash = require('radish-mcp.ghost-flash')
local snapshot = require('radish-mcp.ghost-snapshot')
local watcher = require('radish-mcp.ghost-watcher')

-- Configuration
M.config = {
  enabled = true,
  auto_open_buffer = true,    -- Automatically open buffer when watching starts
  jump_to_first = true,        -- Jump to first change
  center_on_jump = true,       -- Center view on change
  flash_all_chunks = true,     -- Flash all changed chunks, not just first
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Setup sub-modules
  flash.setup(opts and opts.flash or {})
  snapshot.setup(opts and opts.snapshot or {})
  watcher.setup(opts and opts.watcher or {})
end

-- Main orchestrator: Watch for file changes and flash them
-- @param filepath: file to watch (absolute or relative path)
function M.watch_and_flash(filepath)
  if not M.config.enabled then
    if M.debug then
      print("🚫 [Orchestrator] Disabled, skipping")
    end
    return
  end

  filepath = vim.fn.fnamemodify(filepath, ":p")
  print(string.format("🎬 [Orchestrator] Starting watch_and_flash for: %s", vim.fn.fnamemodify(filepath, ":t")))

  -- Step 1: Create snapshot ASAP (race against the write)
  local snap = snapshot.create_snapshot(filepath)
  if not snap then
    vim.notify("Ghost: Failed to create snapshot for " .. vim.fn.fnamemodify(filepath, ":t"),
      vim.log.levels.WARN)
    return
  end
  print(string.format("📸 [Orchestrator] Snapshot created: %s", snap and snap.path or "nil"))

  -- Step 2: Optionally open buffer immediately
  if M.config.auto_open_buffer then
    print("📂 [Orchestrator] Opening buffer...")
    M.open_buffer(filepath)
  end

  -- Step 3: Watch for write completion
  print("👁️  [Orchestrator] Starting watcher...")
  watcher.watch(filepath, function(detected_path)
    print(string.format("🔔 [Orchestrator] Watcher callback triggered for: %s", vim.fn.fnamemodify(detected_path, ":t")))

    -- Give buffer a moment to reload (if auto-reload is enabled)
    vim.defer_fn(function()
      print("⏰ [Orchestrator] Calling on_write_detected after 50ms delay")
      M.on_write_detected(detected_path, snap)
    end, 50)
  end)
end

-- Handle write detection with diff and flash
function M.on_write_detected(filepath, snap)
    -- Step 4: Diff and find changes
  local chunks = snapshot.diff_since_snapshot(filepath, snap)
  print(string.format("🔍 [Orchestrator] Diff completed: %d chunks found", chunks and #chunks or 0))

    -- Cleanup snapshot immediately
    snapshot.cleanup_snapshot(snap)
    print("🧹 [Orchestrator] Snapshot cleaned up")

    if not chunks or #chunks == 0 then
      print("ℹ️  [Orchestrator] No changes detected")
      vim.notify("Ghost: No changes detected in " .. vim.fn.fnamemodify(filepath, ":t"),
        vim.log.levels.INFO)
      return
    end

  print(string.format("📊 [Orchestrator] Changes found: %d chunks", #chunks))
  for i, chunk in ipairs(chunks) do
    print(string.format("  Chunk %d: lines %d-%d", i, chunk.start, chunk.stop))
  end

  -- Ensure buffer is reloaded
  local bufnr = vim.fn.bufnr(filepath)
  if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
    -- Force reload from disk
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("edit!")
    end)
  end
  print("🔄 [Orchestrator] Buffer reloaded")

    -- Step 5: Flash the changes
    print("⚡ [Orchestrator] Calling flash_changes...")
    M.flash_changes(filepath, chunks)
end

-- Helper: Check if window is a terminal
local function is_terminal_window(winid)
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')
  return buftype == 'terminal'
end

-- Helper: Find a suitable non-terminal window
local function find_suitable_window()
  local current_win = vim.api.nvim_get_current_win()

  -- If current window is not a terminal, use it
  if not is_terminal_window(current_win) then
    return current_win
  end

  -- Find any non-terminal window
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if not is_terminal_window(winid) then
      return winid
    end
  end

  -- No suitable window found, create a split
  vim.cmd('split')
  return vim.api.nvim_get_current_win()
end

-- Open buffer in a window (avoiding terminal windows)
function M.open_buffer(filepath)
  local bufnr = vim.fn.bufnr(filepath)

  -- Create buffer if it doesn't exist
  if bufnr == -1 then
    bufnr = vim.fn.bufadd(filepath)
    vim.fn.bufload(bufnr)
  end

  -- Check if already visible in a non-terminal window
  local wins = vim.fn.win_findbuf(bufnr)
  for _, winid in ipairs(wins) do
    if not is_terminal_window(winid) then
      -- Already visible in a good window, just focus it
      print(string.format("📌 [Orchestrator] Buffer already visible in window %d", winid))
      vim.api.nvim_set_current_win(winid)
      return
    end
  end

  -- Not visible in a non-terminal window, open it
  local target_win = find_suitable_window()
  print(string.format("🪟 [Orchestrator] Opening buffer in window %d", target_win))
  vim.api.nvim_set_current_win(target_win)
  vim.api.nvim_win_set_buf(target_win, bufnr)
end

-- Flash changed chunks with visual feedback
function M.flash_changes(filepath, chunks)
  print(string.format("⚡ [Orchestrator.flash_changes] Called with %d chunks", #chunks))
  local bufnr = vim.fn.bufnr(filepath)

  if bufnr == -1 then
    print("❌ [Orchestrator.flash_changes] Buffer not loaded!")
    vim.notify("Ghost: Buffer not loaded for " .. vim.fn.fnamemodify(filepath, ":t"),
      vim.log.levels.WARN)
    return
  end

  -- Jump to first change if enabled
  if M.config.jump_to_first and #chunks > 0 then
    local first_chunk = chunks[1]

    -- Find non-terminal window with this buffer
    local wins = vim.fn.win_findbuf(bufnr)
    local target_win = nil
    for _, winid in ipairs(wins) do
      if not is_terminal_window(winid) then
        target_win = winid
        break
      end
    end

    if target_win then
      -- Validate line number is within buffer
      local line_count = vim.api.nvim_buf_line_count(bufnr)
      if first_chunk.start > line_count then
        vim.notify("Ghost: First change at line " .. first_chunk.start .. " exceeds buffer lines " .. line_count, vim.log.levels.WARN)
        return
      end

      vim.api.nvim_set_current_win(target_win)
      vim.api.nvim_win_set_cursor(target_win, {first_chunk.start, 0})

      if M.config.center_on_jump then
        vim.cmd("normal! zz")
      end
    end
  end

  -- Flash all chunks or just first?
  local chunks_to_flash = M.config.flash_all_chunks and chunks or {chunks[1]}
  print(string.format("⚡ [Orchestrator.flash_changes] Flashing %d chunks", #chunks_to_flash))

  for _, chunk in ipairs(chunks_to_flash) do
    print(string.format("  ⚡ Flashing bufnr=%d lines %d-%d", bufnr, chunk.start, chunk.stop))
    flash.flash_lines(bufnr, chunk.start, chunk.stop)
  end

  -- Log for debugging
  vim.notify(string.format("Ghost: Flashed %d change%s in %s",
    #chunks_to_flash,
    #chunks_to_flash == 1 and "" or "s",
    vim.fn.fnamemodify(filepath, ":t")),
    vim.log.levels.INFO)
end

-- Manual trigger for testing
-- Creates a snapshot, lets you make changes, then diffs and flashes
function M.test_manual_diff(filepath)
  filepath = vim.fn.fnamemodify(filepath, ":p")

  local snap = snapshot.create_snapshot(filepath)
  if not snap then
    vim.notify("Failed to create snapshot", vim.log.levels.ERROR)
    return
  end

  vim.notify("📸 Snapshot created. Make your changes, then press any key...", vim.log.levels.INFO)

  -- Wait for user input
  vim.fn.getchar()

  -- Diff and flash
  local chunks = snapshot.diff_since_snapshot(filepath, snap)
  snapshot.cleanup_snapshot(snap)

  if chunks and #chunks > 0 then
    M.flash_changes(filepath, chunks)
  else
    vim.notify("No changes detected", vim.log.levels.INFO)
  end
end

-- Initialize
M.setup()

return M
