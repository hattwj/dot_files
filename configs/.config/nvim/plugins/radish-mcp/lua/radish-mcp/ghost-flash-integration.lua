-- Ghost Flash Integration - Terminal pattern detection for WriteFile operations
local M = {}

local pattern_registry = require('radish-mcp.pattern-registry')
local orchestrator = require('radish-mcp.ghost-flash-orchestrator')

M.config = {
  enabled = true,
  priority = 50,  -- Run before generic file patterns
}

-- Pattern matchers for WriteFile operations
local WRITEFILE_PATTERNS = {
  -- JSON format from tool calls
  '"filepath"%s*:%s*"([^"]+)"',

  -- Plain text formats
  'Writing to:%s*([^%s]+)',
  'Updated:%s*([^%s%(]+)',
  'Modified:%s*([^%s%(]+)',

  -- Success messages
  'File.*updated:%s*([^%s]+)',
  '✅.*Updated:%s*([^%s]+)',
}

-- Extract filepath from a line
local function extract_filepath(line)
  -- Validate input
  if type(line) ~= "string" then
    return nil
  end

  for _, pattern in ipairs(WRITEFILE_PATTERNS) do
    local ok, match = pcall(function()
      return line:match(pattern)
    end)

    if not ok then
      -- Pattern matching failed, skip this pattern
      goto continue
    end

    if match then
      -- Clean up the match
      match = vim.trim(match)

      -- Try as-is first
      local expanded = vim.fn.expand(match)
      if vim.fn.filereadable(expanded) == 1 then
        return expanded
      end

      -- Try with current working directory
      local with_cwd = vim.fn.getcwd() .. "/" .. match
      if vim.fn.filereadable(with_cwd) == 1 then
        return vim.fn.fnamemodify(with_cwd, ":p")
      end

      -- Try searching in common locations
      local search_paths = {
        "configs/.config/nvim/plugins/radish-mcp/lua/radish-mcp/" .. match,
        "configs/.config/nvim/plugins/term-popup/lua/term-popup/" .. match,
      }

      for _, search_path in ipairs(search_paths) do
        local search_expanded = vim.fn.expand(search_path)
        if vim.fn.filereadable(search_expanded) == 1 then
          return vim.fn.fnamemodify(search_expanded, ":p")
        end
      end
    end
    ::continue::
  end

  return nil
end

-- Setup integration with pattern registry
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  if not M.config.enabled then
    return
  end

  print("🔌 [Integration] Registering WriteFile pattern handler")

  -- Register WriteFile detection pattern
  pattern_registry.register({
    name = "ghost_flash_writefile",
    pattern = "WriteFile",  -- Quick pre-filter
    priority = M.config.priority,
    description = "Detects WriteFile operations and triggers ghost flash",

    handler = function(line, context)
      -- Debug log for potential WriteFile lines
      if type(line) == "string" and line:match("WriteFile") then
        print(string.format("🔍 [Integration] Potential WriteFile line: %s", line:sub(1, 80)))
      end

      -- Defensive: ensure line is a string
      if type(line) ~= "string" then
        return false
      end

      -- Extract filepath from line
      local filepath = extract_filepath(line)

      if not filepath then
        -- Not a WriteFile line, that's fine
        return false  -- Pattern didn't match, continue processing
      end

      print(string.format("🎯 [Integration] WriteFile detected! File: %s", filepath))

      -- Trigger watch and flash
      vim.schedule(function()
        orchestrator.watch_and_flash(filepath)
      end)

      return false  -- Allow other patterns to process too
    end
  })

  -- Also register a broader pattern for "filepath" keyword
  pattern_registry.register({
    name = "ghost_flash_filepath_keyword",
    pattern = "filepath",
    priority = M.config.priority + 1,  -- Slightly lower priority
    description = "Detects 'filepath' keyword and triggers ghost flash",

    handler = function(line, context)
      -- Validate line is a string
      if type(line) ~= "string" then
        return false
      end

      -- Only trigger if we see specific keywords indicating a write
      if not (line:match("Writing") or line:match("Updated") or line:match("Modified")) then
        return false
      end

      local filepath = extract_filepath(line)

      if not filepath then
        return false
      end

      vim.schedule(function()
        orchestrator.watch_and_flash(filepath)
      end)

      return false
    end
  })
end

-- Manual trigger for testing
function M.test_pattern(line)
  local filepath = extract_filepath(line)
  if filepath then
    print("✅ Extracted: " .. filepath)
    orchestrator.watch_and_flash(filepath)
  else
    print("❌ No filepath found in: " .. line)
  end
end

return M
