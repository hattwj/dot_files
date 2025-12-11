-- Ghost Watcher - File modification detection via polling
local M = {}

-- Debug logging flag
M.debug = true

-- Configuration
M.config = {
  poll_interval_ms = 50,      -- Check every 50ms
  max_wait_ms = 90000,        -- Timeout after 90 seconds (WriteFile can be slow)
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

-- Wait for file modification and trigger callback
-- @param filepath: path to file to watch
-- @param callback: function(detected: boolean) - called on completion or timeout
-- @param original_mtime: optional baseline mtime (if nil, uses current)
function M.wait_for_write(filepath, callback, original_mtime)
  filepath = vim.fn.fnamemodify(filepath, ":p")

  if M.debug then
    print(string.format("🔍 [Watcher] Starting watch for: %s", vim.fn.fnamemodify(filepath, ":t")))
  end

  -- Get baseline mtime
  if not original_mtime then
    local stat = vim.loop.fs_stat(filepath)
    if not stat then
      -- File doesn't exist yet, watch for creation
      if M.debug then
        print("📝 [Watcher] File doesn't exist, watching for creation")
      end
      M.wait_for_creation(filepath, callback)
      return
    end
    original_mtime = stat.mtime.sec
    if M.debug then
      print(string.format("🕐 [Watcher] Baseline mtime: %d", original_mtime))
    end
  end

  local elapsed = 0
  local timer = vim.loop.new_timer()

  timer:start(0, M.config.poll_interval_ms, vim.schedule_wrap(function()
    elapsed = elapsed + M.config.poll_interval_ms

    -- Check if file modified
    local stat = vim.loop.fs_stat(filepath)
    if stat and stat.mtime.sec > original_mtime then
      -- Write detected!
      if M.debug then
        print(string.format("✅ [Watcher] WRITE DETECTED! %s (elapsed: %dms, mtime: %d -> %d)",
          vim.fn.fnamemodify(filepath, ":t"), elapsed, original_mtime, stat.mtime.sec))
      end
      timer:stop()
      timer:close()
      callback(true)
      return
    end

    -- Timeout check
    if elapsed >= M.config.max_wait_ms then
      if M.debug then
        print(string.format("⏱️  [Watcher] TIMEOUT! %s (waited %dms)",
          vim.fn.fnamemodify(filepath, ":t"), elapsed))
      end
      timer:stop()
      timer:close()
      callback(false)
    end
  end))
end

-- Wait for file creation (for new files)
-- @param filepath: path to file
-- @param callback: function(created: boolean)
function M.wait_for_creation(filepath, callback)
  local elapsed = 0
  local timer = vim.loop.new_timer()

  timer:start(0, M.config.poll_interval_ms, vim.schedule_wrap(function()
    elapsed = elapsed + M.config.poll_interval_ms

    -- Check if file exists now
    local stat = vim.loop.fs_stat(filepath)
    if stat then
      -- File created!
      if M.debug then
        print(string.format("✅ [Watcher] FILE CREATED! %s (elapsed: %dms)",
          vim.fn.fnamemodify(filepath, ":t"), elapsed))
      end
      timer:stop()
      timer:close()
      callback(true)
      return
    end

    -- Timeout
    if elapsed >= M.config.max_wait_ms then
      if M.debug then
        print(string.format("⏱️  [Watcher] CREATION TIMEOUT! %s (waited %dms)",
          vim.fn.fnamemodify(filepath, ":t"), elapsed))
      end
      timer:stop()
      timer:close()
      callback(false)
    end
  end))
end

-- High-level API: Start watching before a write operation
-- @param filepath: file to watch
-- @param on_write: function(filepath) - called when write completes
-- @return watcher object with cancel() method
function M.watch(filepath, on_write)
  filepath = vim.fn.fnamemodify(filepath, ":p")

  -- Capture current mtime
  local stat = vim.loop.fs_stat(filepath)
  local original_mtime = stat and stat.mtime.sec or nil

  local watcher = {
    filepath = filepath,
    cancelled = false,
  }

  -- Start watching
  M.wait_for_write(filepath, function(detected)
    if watcher.cancelled then
      return
    end

    if detected then
      on_write(filepath)
    else
      vim.notify("Ghost Watcher: Timeout waiting for " .. vim.fn.fnamemodify(filepath, ":t"),
        vim.log.levels.WARN)
    end
  end, original_mtime)

  -- Return cancellable watcher
  function watcher.cancel()
    watcher.cancelled = true
  end

  return watcher
end

-- Initialize
M.setup()

return M
