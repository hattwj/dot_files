-- Tree-sitter AST tools for structural code navigation
-- Provides scope analysis, node ranges, siblings, and children queries
-- All tools use line number as the universal anchor
local M = {}

-- ── Shared helpers ──────────────────────────────────────────────────

local function mcp_result(data)
  return {
    content = {
      { type = "text", text = vim.json.encode(data) }
    }
  }
end

local MAX_FILE_SIZE = 1024 * 1024

local function get_or_load_buffer(filepath)
  if not filepath or filepath == "" then
    return vim.api.nvim_get_current_buf(), nil
  end
  filepath = vim.fn.fnamemodify(filepath, ":p")
  local bufnr = vim.fn.bufnr(filepath)
  if bufnr ~= -1 then
    return bufnr, nil
  end
  if vim.fn.filereadable(filepath) ~= 1 then
    return nil, "File not found: " .. filepath
  end
  local stat = vim.loop.fs_stat(filepath)
  if stat and stat.size > MAX_FILE_SIZE then
    return nil, string.format("File too large (%d bytes)", stat.size)
  end
  bufnr = vim.fn.bufadd(filepath)
  if bufnr == 0 then
    return nil, "Failed to add buffer for: " .. filepath
  end
  vim.cmd("noswapfile silent! call bufload(" .. bufnr .. ")")
  return bufnr, nil
end

local function get_parser(bufnr)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return nil, "No tree-sitter parser available for this buffer"
  end
  parser:parse()
  return parser, nil
end

local function get_root(parser)
  local trees = parser:trees()
  if not trees or #trees == 0 then
    return nil, "No parse tree available"
  end
  return trees[1]:root(), nil
end

-- Get the smallest named node at a given line (0-indexed internally, 1-indexed input)
local function node_at_line(root, line_1indexed)
  local line = line_1indexed - 1
  local node = root:named_descendant_for_range(line, 0, line, 0)
  return node
end

-- Walk up to the nearest "interesting" node (skip identifiers, operators, etc.)
local function meaningful_node(node)
  while node do
    local t = node:type()
    -- Skip leaf-level tokens that aren't structurally meaningful
    if t ~= "identifier" and t ~= "constant" and t ~= "string_content"
       and t ~= "simple_symbol" and t ~= "hash_key_symbol"
       and t ~= "integer" and t ~= "true" and t ~= "false"
       and not t:match("^%l") == false then
      break
    end
    -- If parent is more meaningful, prefer it
    local parent = node:parent()
    if parent and parent:start() == node:start() then
      node = parent
    else
      break
    end
  end
  return node
end

-- Extract a readable name for a node
local function node_name(node, bufnr)
  local t = node:type()

  -- For method definitions, get the method name
  if t == "method" or t == "singleton_method" or t == "method_definition"
     or t == "function_definition" or t == "function_declaration" then
    for child in node:iter_children() do
      if child:type() == "identifier" or child:type() == "property_identifier"
         or child:type() == "name" then
        return vim.treesitter.get_node_text(child, bufnr)
      end
    end
  end

  -- For calls (shared_context, describe, context, it, etc.), get name + first string arg
  if t == "call" or t == "method_call" or t == "call_expression" then
    local parts = {}
    for child in node:iter_children() do
      local ct = child:type()
      if ct == "identifier" or ct == "scope_resolution" or ct == "constant" then
        table.insert(parts, vim.treesitter.get_node_text(child, bufnr))
      elseif ct == "argument_list" or ct == "arguments" then
        for arg in child:iter_children() do
          if arg:type() == "string" or arg:type() == "string_literal" then
            local text = vim.treesitter.get_node_text(arg, bufnr)
            table.insert(parts, text)
            break
          end
        end
        break
      end
    end
    if #parts > 0 then
      return table.concat(parts, " ")
    end
  end

  -- For class/module definitions
  if t == "class" or t == "module" or t == "class_declaration" then
    for child in node:iter_children() do
      if child:type() == "constant" or child:type() == "scope_resolution"
         or child:type() == "type_identifier" or child:type() == "name" then
        return vim.treesitter.get_node_text(child, bufnr)
      end
    end
  end

  -- For assignments
  if t == "assignment" or t == "variable_declaration" then
    local first = node:named_child(0)
    if first then
      return vim.treesitter.get_node_text(first, bufnr)
    end
  end

  -- Fallback: first line of node text, truncated
  local text = vim.treesitter.get_node_text(node, bufnr)
  if text then
    local first_line = text:match("^[^\n]*")
    if first_line and #first_line > 80 then
      first_line = first_line:sub(1, 77) .. "..."
    end
    return first_line
  end

  return t
end

local function node_info(node, bufnr)
  local sr, sc, er, ec = node:range()
  return {
    type = node:type(),
    name = node_name(node, bufnr),
    start_line = sr + 1,
    end_line = er + 1,
    start_col = sc,
    end_col = ec,
  }
end

local function matches_type_filter(node, node_type)
  if not node_type then return true end
  local t = node:type()
  -- Allow partial matching: "method" matches "method", "method_definition", etc.
  return t == node_type or t:find(node_type, 1, true) ~= nil
end

-- ── vim_ast_scope ───────────────────────────────────────────────────

local function handle_scope(arguments)
  local bufnr, err = get_or_load_buffer(arguments.file)
  if err then return mcp_result({ error = err }) end

  local parser, perr = get_parser(bufnr)
  if perr then return mcp_result({ error = perr }) end

  local root, rerr = get_root(parser)
  if rerr then return mcp_result({ error = rerr }) end

  local node = node_at_line(root, arguments.line)
  if not node then
    return mcp_result({ error = "No node found at line " .. arguments.line })
  end

  local scope_chain = {}
  local current = node
  while current do
    if current:named() and current ~= root then
      table.insert(scope_chain, 1, node_info(current, bufnr))
    end
    current = current:parent()
  end

  return mcp_result({
    line = arguments.line,
    depth = #scope_chain,
    scope = scope_chain,
  })
end

-- ── vim_ast_node_range ──────────────────────────────────────────────

local function handle_node_range(arguments)
  local bufnr, err = get_or_load_buffer(arguments.file)
  if err then return mcp_result({ error = err }) end

  local parser, perr = get_parser(bufnr)
  if perr then return mcp_result({ error = perr }) end

  local root, rerr = get_root(parser)
  if rerr then return mcp_result({ error = rerr }) end

  local node = node_at_line(root, arguments.line)
  if not node then
    return mcp_result({ error = "No node found at line " .. arguments.line })
  end

  -- Walk up to the nearest block-level node
  node = meaningful_node(node)

  local info = node_info(node, bufnr)
  info.line_count = info.end_line - info.start_line + 1

  return mcp_result(info)
end

-- ── vim_ast_siblings ────────────────────────────────────────────────

local function handle_siblings(arguments)
  local bufnr, err = get_or_load_buffer(arguments.file)
  if err then return mcp_result({ error = err }) end

  local parser, perr = get_parser(bufnr)
  if perr then return mcp_result({ error = perr }) end

  local root, rerr = get_root(parser)
  if rerr then return mcp_result({ error = rerr }) end

  local parent
  if arguments.line then
    local node = node_at_line(root, arguments.line)
    if not node then
      return mcp_result({ error = "No node found at line " .. arguments.line })
    end
    node = meaningful_node(node)
    parent = node:parent() or root
  else
    parent = root
  end

  local siblings = {}
  for child in parent:iter_children() do
    if child:named() and matches_type_filter(child, arguments.node_type) then
      table.insert(siblings, node_info(child, bufnr))
    end
  end

  return mcp_result({
    parent_type = parent:type(),
    parent_range = { parent:range() },
    count = #siblings,
    siblings = siblings,
  })
end

-- ── vim_ast_children ────────────────────────────────────────────────

local function handle_children(arguments)
  local bufnr, err = get_or_load_buffer(arguments.file)
  if err then return mcp_result({ error = err }) end

  local parser, perr = get_parser(bufnr)
  if perr then return mcp_result({ error = perr }) end

  local root, rerr = get_root(parser)
  if rerr then return mcp_result({ error = rerr }) end

  local node = node_at_line(root, arguments.line)
  if not node then
    return mcp_result({ error = "No node found at line " .. arguments.line })
  end

  node = meaningful_node(node)

  local children = {}
  for child in node:iter_children() do
    if child:named() and matches_type_filter(child, arguments.node_type) then
      table.insert(children, node_info(child, bufnr))
    end
  end

  local info = node_info(node, bufnr)
  info.child_count = #children
  info.children = children

  return mcp_result(info)
end

-- ── Schema definitions ──────────────────────────────────────────────

M.schemas = {
  {
    name = "vim_ast_scope",
    description = "Returns the nesting stack (scope chain) for a given line. " ..
      "Shows every enclosing node from the line up to the file root. " ..
      "Useful for understanding if a definition is standalone or nested inside a block.",
    inputSchema = {
      type = "object",
      properties = {
        line = { type = "number", description = "Line number (1-indexed)" },
        file = { type = "string", description = "File path (defaults to current buffer)" },
      },
      required = { "line" },
    },
  },
  {
    name = "vim_ast_node_range",
    description = "Returns the exact start and end line of the enclosing block at a given line. " ..
      "Tree-sitter knows block boundaries exactly — no guessing where 'end' is.",
    inputSchema = {
      type = "object",
      properties = {
        line = { type = "number", description = "Any line inside the node (1-indexed)" },
        file = { type = "string", description = "File path (defaults to current buffer)" },
      },
      required = { "line" },
    },
  },
  {
    name = "vim_ast_siblings",
    description = "List all named nodes at the same scope level as the given line. " ..
      "If no line given, returns top-level nodes (table-of-contents view). " ..
      "Optionally filter by node type (e.g. 'method', 'call', 'class').",
    inputSchema = {
      type = "object",
      properties = {
        line = { type = "number", description = "Line to find siblings of (omit for root level)" },
        node_type = { type = "string", description = "Filter by node type (e.g. 'method', 'call')" },
        file = { type = "string", description = "File path (defaults to current buffer)" },
      },
    },
  },
  {
    name = "vim_ast_children",
    description = "List all named child nodes inside the block at a given line. " ..
      "Shows what's defined inside a block — methods, before/after hooks, nested contexts. " ..
      "Optionally filter by node type.",
    inputSchema = {
      type = "object",
      properties = {
        line = { type = "number", description = "Line of the parent node (1-indexed)" },
        node_type = { type = "string", description = "Filter by node type (e.g. 'method', 'call')" },
        file = { type = "string", description = "File path (defaults to current buffer)" },
      },
      required = { "line" },
    },
  },
}

M.handlers = {
  vim_ast_scope = handle_scope,
  vim_ast_node_range = handle_node_range,
  vim_ast_siblings = handle_siblings,
  vim_ast_children = handle_children,
}

return M
