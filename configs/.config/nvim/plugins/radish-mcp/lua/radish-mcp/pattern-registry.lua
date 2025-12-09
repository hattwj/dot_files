-- Pattern Registry: Core system for extensible line matching
-- Allows registration of patterns with handlers that process terminal output

local M = {}

-- Internal registry storage
local registry = {}

-- Register a new pattern
-- @param config table: {name, pattern, handler, priority?, enabled?, description?}
-- @return table: the registered pattern definition
function M.register(config)
  -- Validate required fields
  if not config.name then
    error("Pattern must have 'name' field")
  end
  if not config.pattern then
    error("Pattern must have 'pattern' field")
  end
  if not config.handler then
    error("Pattern must have 'handler' function")
  end
  if type(config.handler) ~= "function" then
    error("Pattern 'handler' must be a function")
  end

  -- Check for duplicate names
  for _, existing in ipairs(registry) do
    if existing.name == config.name then
      error(string.format("Pattern '%s' already registered", config.name))
    end
  end

  local pattern_def = {
    name = config.name,
    pattern = config.pattern,
    handler = config.handler,
    enabled = config.enabled ~= false,  -- Default true
    priority = config.priority or 100,  -- Default priority
    description = config.description or "",
  }

  table.insert(registry, pattern_def)

  -- Sort by priority (lower number = higher priority)
  table.sort(registry, function(a, b)
    return a.priority < b.priority
  end)

  return pattern_def
end

-- Unregister a pattern by name
-- @param name string: pattern name
-- @return boolean: true if found and removed
function M.unregister(name)
  for i, pattern in ipairs(registry) do
    if pattern.name == name then
      table.remove(registry, i)
      return true
    end
  end
  return false
end

-- Enable or disable a pattern
-- @param name string: pattern name
-- @param enabled boolean: new enabled state
-- @return boolean: true if found and updated
function M.set_enabled(name, enabled)
  for _, pattern in ipairs(registry) do
    if pattern.name == name then
      pattern.enabled = enabled
      return true
    end
  end
  return false
end

-- Get all registered patterns
-- @return table: array of pattern definitions
function M.get_patterns()
  return vim.deepcopy(registry)
end

-- List patterns in a human-readable format
-- @return table: array of formatted strings
function M.list_patterns()
  local lines = {}
  for i, pattern in ipairs(registry) do
    local status = pattern.enabled and "✓" or "✗"
    table.insert(lines, string.format(
      "%s [%3d] %-20s %s",
      status,
      pattern.priority,
      pattern.name,
      pattern.description
    ))
  end
  return lines
end

-- Display patterns in floating window
function M.show_patterns()
  local lines = {"Radish Pattern Registry:", ""}
  vim.list_extend(lines, M.list_patterns())

  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

  -- Calculate window size
  local width = 80
  local height = math.min(#lines + 2, 20)

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    border = 'rounded',
    title = " Radish Patterns ",
    title_pos = "center",
  })

  -- Set buffer-local keymaps to close
  vim.keymap.set('n', 'q', ':close<CR>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', ':close<CR>', { buffer = buf, silent = true })
end

-- Process a single line against all enabled patterns
-- @param line string: the line to process
-- @param context table: optional context passed to handlers
-- @return any: result from handler if one matched and returned value
function M.process_line(line, context)
  context = context or {}

  for _, pattern_def in ipairs(registry) do
    if pattern_def.enabled then
      -- Try to match pattern
      local matches = {line:match(pattern_def.pattern)}

      if #matches > 0 then
        -- Call handler with matches and context
        local ok, result = pcall(pattern_def.handler, matches, context)

        if not ok then
          vim.notify(
            string.format("Pattern '%s' handler error: %s", pattern_def.name, result),
            vim.log.levels.ERROR
          )
        elseif result then
          -- Handler returned truthy value - stop processing
          return result
        end
      end
    end
  end

  return nil
end

-- Clear all registered patterns
function M.clear()
  registry = {}
end

-- Get count of registered patterns
function M.count()
  return #registry
end

return M
