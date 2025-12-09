-- Custom :Ag command with file type filtering
-- Usage: :Ag something --ruby
--        :Ag --js potato
--        :Ag error message --python
--        :Ag '--foobar' .  (searches for literal '--foobar')
--        :Ag --txt something  (searches *.txt files even though not in table)
-- Visual mode: Select text, then :'<,'>Ag --cpp

local M = {}

-- File type extension mappings
local file_types = {
  c = { "*.c", "*.h" },
  cpp = { "*.cpp", "*.cc", "*.cxx", "*.hpp", "*.hxx" },
  go = { "*.go" },
  html = { "*.html" },
  java = { "*.java" },
  javascript = { "*.js", "*.jsx", "*.mjs", "*.cjs" },
  js = { "*.js", "*.jsx", "*.mjs", "*.cjs" },
  json = { "*.json" },
  kotlin = { "*.kt", "*.kts" },
  kt = { "*.kt", "*.kts" },
  lua = { "*.lua" },
  markdown = { "*.md", "*.markdown" },
  md = { "*.md", "*.markdown" },
  py = { "*.py", "*.pyw" },
  python = { "*.py", "*.pyw" },
  rb = { "*.rb", "*.rake", "Rakefile", "Gemfile", "*.gemspec" },
  rs = { "*.rs" },
  ruby = { "*.rb", "*.rake", "Rakefile", "Gemfile", "*.gemspec" },
  rust = { "*.rs" },
  scala = { "*.scala" },
  sh = { "*.sh", "*.bash", "*.zsh" },
  shell = { "*.sh", "*.bash", "*.zsh" },
  ts = { "*.ts", "*.tsx" },
  typescript = { "*.ts", "*.tsx" },
  xml = { "*.xml" },
  yaml = { "*.yml", "*.yaml" },
  yml = { "*.yml", "*.yaml" },
}

-- Check if a string looks like a path
local function looks_like_path(str)
  -- Starts with ./ ../ / ~ or contains /
  return str:match("^[.~/]") or str:match("/")
end

-- Parse search query, file type flags, and path
-- Handles backslash-escaped strings to preserve literal --flags as search terms
-- Example: \--foo will search for literal "--foo" instead of treating as flag
local function parse_ag_args(args)
  local query_parts = {}
  local file_type = nil
  local search_path = nil
  local words = {}
  local escaped_map = {}  -- Track which words were backslash-escaped

  -- Split args into words, detecting backslash-escaped words
  for word in args:gmatch("%S+") do
    local was_escaped = false
    -- Check if word starts with backslash
    local unescaped = word:match("^\\(.+)$")
    if unescaped then
      word = unescaped  -- Remove leading backslash
      was_escaped = true
    end
    table.insert(words, word)
    escaped_map[#words] = was_escaped
  end

  -- Check if last word is a path (but not if it was escaped)
  if #words > 0 and not escaped_map[#words] then
    local last_word = words[#words]
    if looks_like_path(last_word) then
      search_path = last_word
      table.remove(words)  -- Remove path from words
      escaped_map[#words] = nil
    end
  end

  -- Parse remaining words for query and file type (--flag can be anywhere)
  for i, word in ipairs(words) do
    -- If the word was escaped, treat it as a literal search term
    if escaped_map[i] then
      table.insert(query_parts, word)
    else
      -- Check if it's a file type flag (--type)
      local flag_type = word:match("^%-%-(.+)$")
      if flag_type then
        -- Check if it's in our table, otherwise use as wildcard *.flag_type
        file_type = file_types[flag_type] and flag_type or flag_type
      else
        table.insert(query_parts, word)
      end
    end
  end

  local query = table.concat(query_parts, " ")
  return query, file_type, search_path
end

-- Get visually selected text
local function get_visual_selection()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local start_line = start_pos[2]
  local end_line = end_pos[2]
  local start_col = start_pos[3]
  local end_col = end_pos[3]

  local lines = vim.fn.getline(start_line, end_line)
  if #lines == 0 then return "" end
  lines[#lines] = string.sub(lines[#lines], 1, end_col)
  lines[1] = string.sub(lines[1], start_col)
  return table.concat(lines, " ")
end

function M.setup(opts)
  opts = opts or {}

  -- Create :Ag command with range support
  vim.api.nvim_create_user_command("Ag", function(cmd_opts)
    local query, file_type, search_path = parse_ag_args(cmd_opts.args)

    -- If called with range (visual selection), use selected text as query
    if cmd_opts.range > 0 then
      query = get_visual_selection()
    end

    if query == "" then
      vim.notify("No search query provided", vim.log.levels.WARN)
      return
    end

    local telescope_opts = {
      default_text = query,
    }

    -- Add file type filtering if specified
    if file_type then
      local globs = file_types[file_type]
      -- If file_type not in table, create wildcard pattern *.type
      if not globs then
        globs = { "*." .. file_type }
        telescope_opts.prompt_title = "Grep (*." .. file_type .. " files)"
      else
        telescope_opts.prompt_title = "Grep (" .. file_type .. " files)"
      end

      telescope_opts.prompt_title = "Grep (" .. file_type .. " files)"
      telescope_opts.vimgrep_arguments = vim.list_extend(
        { "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
        vim.tbl_map(function(glob) return "--glob=" .. glob end, globs)
      )
    end

    -- Add path restriction if specified
    if search_path then
      -- Expand path relative to current directory
      local expanded_path = vim.fn.expand(search_path)
      if vim.fn.isdirectory(expanded_path) == 1 then
        telescope_opts.search_dirs = { expanded_path }
        telescope_opts.prompt_title = (telescope_opts.prompt_title or "Grep") .. " in " .. search_path
      else
        vim.notify("Path not found: " .. search_path, vim.log.levels.WARN)
      end
    end

    require("telescope.builtin").live_grep(telescope_opts)
  end, {
    nargs = "*",
    range = true,
    complete = "file",
    desc = "Search with optional file type (e.g., :Ag query --ruby or visual select then :'<,'>Ag --cpp)",
  })
end

return M
