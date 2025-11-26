-- Tool registry for Radish MCP
local M = {}

-- Load all tool modules
local tools = {
  buffer = require("radish-mcp.tools.buffer"),
  status = require("radish-mcp.tools.status"),
  command = require("radish-mcp.tools.command"),
  context = require("radish-mcp.tools.context"),
  preview = require("radish-mcp.tools.preview"),
  file = require("radish-mcp.tools.file"),
  lsp = require("radish-mcp.tools.lsp"),
  messages = require("radish-mcp.tools.messages"),
}

-- Get all tool schemas for tools/list
function M.get_schemas()
  local schemas = {}
  for _, tool in pairs(tools) do
    if tool.schemas then
      -- Tool module exports multiple schemas
      for _, schema in ipairs(tool.schemas) do
        table.insert(schemas, schema)
      end
    else
      -- Tool module exports single schema
      table.insert(schemas, tool.schema)
    end
  end
  return schemas
end

-- Execute a tool by name
function M.execute(tool_name, arguments)
  -- Find the tool handler
  for _, tool in pairs(tools) do
    if tool.schema and tool.schema.name == tool_name then
      return tool.handler(arguments)
    elseif tool.handlers and tool.handlers[tool_name] then
      return tool.handlers[tool_name](arguments)
    end
  end

  error("Unknown tool: " .. tool_name)
end

return M
