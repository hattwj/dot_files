-- Ghost Snapshot - File snapshot system for change detection
local M = {}

-- Configuration
M.config = {
  cache_dir = vim.fn.stdpath("cache") .. "/ghost-snapshots",
  max_age_seconds = 300,  -- Auto-cleanup snapshots older than 5 minutes
}

-- Setup cache directory
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Ensure cache directory exists
  vim.fn.mkdir(M.config.cache_dir, "p")
end

-- Generate stable hash for filepath
local function get_snapshot_path(filepath)
  local hash = vim.fn.sha256(filepath)
  return M.config.cache_dir .. "/" .. hash
end

-- Create snapshot of a file
-- @param filepath: absolute path to file
-- @return snapshot metadata table or nil on failure
function M.create_snapshot(filepath)
  -- Resolve to absolute path
  filepath = vim.fn.fnamemodify(filepath, ":p")

  -- Check if file exists
  if vim.fn.filereadable(filepath) ~= 1 then
    vim.notify("Ghost Snapshot: File not readable: " .. filepath, vim.log.levels.WARN)
    return nil
  end

  local snapshot_path = get_snapshot_path(filepath)

  -- Copy file using vim.loop (uv)
  local ok, err = pcall(function()
    vim.loop.fs_copyfile(filepath, snapshot_path)
  end)

  if not ok then
    vim.notify("Ghost Snapshot: Failed to copy file: " .. tostring(err), vim.log.levels.ERROR)
    return nil
  end

  -- Return metadata
  return {
    path = snapshot_path,
    original = filepath,
    timestamp = os.time(),
  }
end

-- Read snapshot contents
-- @param snapshot: snapshot metadata from create_snapshot()
-- @return array of lines or nil on failure
function M.read_snapshot(snapshot)
  if not snapshot or not snapshot.path then
    return nil
  end

  local ok, lines = pcall(vim.fn.readfile, snapshot.path)
  if not ok then
    vim.notify("Ghost Snapshot: Failed to read snapshot", vim.log.levels.ERROR)
    return nil
  end

  return lines
end

-- Delete a snapshot file
-- @param snapshot: snapshot metadata from create_snapshot()
function M.cleanup_snapshot(snapshot)
  if not snapshot or not snapshot.path then
    return
  end

  pcall(vim.loop.fs_unlink, snapshot.path)
end

-- Clean up old snapshots based on age
function M.cleanup_old_snapshots()
  local current_time = os.time()
  local max_age = M.config.max_age_seconds

  -- List all files in cache directory
  local ok, files = pcall(vim.fn.readdir, M.config.cache_dir)
  if not ok then
    return
  end

  for _, filename in ipairs(files) do
    local filepath = M.config.cache_dir .. "/" .. filename
    local stat = vim.loop.fs_stat(filepath)

    if stat then
      local age = current_time - stat.mtime.sec
      if age > max_age then
        pcall(vim.loop.fs_unlink, filepath)
      end
    end
  end
end

-- Find changed line chunks between old and new content
-- @param old_lines: array of lines from snapshot
-- @param new_lines: array of lines from current file
-- @return array of chunks: {{start=N, stop=M}, ...}
function M.find_change_chunks(old_lines, new_lines)
  local chunks = {}
  local in_chunk = false
  local chunk_start = nil

  local max_lines = math.max(#old_lines, #new_lines)

  for i = 1, max_lines do
    local old_line = old_lines[i] or ""
    local new_line = new_lines[i] or ""
    local changed = old_line ~= new_line

    if changed and not in_chunk then
      -- Start of new chunk
      chunk_start = i
      in_chunk = true
    elseif not changed and in_chunk then
      -- End of chunk
      table.insert(chunks, {start = chunk_start, stop = i - 1})
      in_chunk = false
    end
  end

  -- Handle chunk extending to EOF
  if in_chunk then
    table.insert(chunks, {start = chunk_start, stop = max_lines})
  end

  return chunks
end

-- High-level API: Snapshot -> Wait -> Diff
-- Creates snapshot, compares with current file, returns changes
-- @param filepath: path to file
-- @return chunks array or nil if no snapshot/changes
function M.diff_since_snapshot(filepath, snapshot)
  if not snapshot then
    return nil
  end

  local old_lines = M.read_snapshot(snapshot)
  if not old_lines then
    return nil
  end

  -- Read current file
  local ok, new_lines = pcall(vim.fn.readfile, filepath)
  if not ok then
    return nil
  end

  return M.find_change_chunks(old_lines, new_lines)
end

-- Initialize
M.setup()

return M
