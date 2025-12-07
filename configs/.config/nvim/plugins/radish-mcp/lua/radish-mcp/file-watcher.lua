-- File Watcher - Monitors files for changes using inotify or polling
local M = {}

-- Track watched files and their callbacks
local watches = {}

-- Watch a file for changes
function M.watch(filepath, callback)
  -- Expand path
  local full_path = vim.fn.expand(filepath)

  -- Already watching this file
  if watches[full_path] then
    return
  end

  -- Store callback
  watches[full_path] = {
    callback = callback,
    last_mtime = vim.fn.getftime(full_path),
    timer = nil
  }

  -- Set up polling timer (fallback - inotify would be better but requires external lib)
  local timer = vim.loop.new_timer()
  watches[full_path].timer = timer

  timer:start(500, 500, vim.schedule_wrap(function()
    local current_mtime = vim.fn.getftime(full_path)
    local watch = watches[full_path]

    if not watch then
      timer:stop()
      timer:close()
      return
    end

    if current_mtime > watch.last_mtime then
      watch.last_mtime = current_mtime

      -- File changed - invoke callback
      watch.callback({
        type = "modify",
        file = full_path,
        mtime = current_mtime
      })
    end
  end))
end

-- Stop watching a file
function M.unwatch(filepath)
  local full_path = vim.fn.expand(filepath)
  local watch = watches[full_path]

  if watch and watch.timer then
    watch.timer:stop()
    watch.timer:close()
    watches[full_path] = nil
  end
end

-- Stop watching all files
function M.unwatch_all()
  for filepath, watch in pairs(watches) do
    if watch.timer then
      watch.timer:stop()
      watch.timer:close()
    end
  end
  watches = {}
end

-- Get list of watched files
function M.get_watched()
  local files = {}
  for filepath, _ in pairs(watches) do
    table.insert(files, filepath)
  end
  return files
end

return M
