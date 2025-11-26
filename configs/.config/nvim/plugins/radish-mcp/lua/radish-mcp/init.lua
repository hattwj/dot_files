-- Radish MCP Server for Neovim
-- Implements Model Context Protocol over Unix domain socket
-- Each neovim instance gets its own socket based on TTY

local M = {}

-- Plugin state
M.server = nil
M.socket_path = nil

-- Get unique socket path based on TTY
local function get_socket_path()
  local tty = vim.fn.system("tty"):gsub("\n", "")

  if tty == "" or tty == "not a tty" then
    -- Fallback for non-TTY environments (like nvim running in daemon mode)
    local pid = vim.fn.getpid()
    return "/tmp/radish-nvim-pid-" .. pid .. ".sock"
  end

  -- Convert /dev/pts/5 -> pts-5
  -- Convert /dev/tty1 -> tty1
  local safe_name = tty:gsub("^/dev/", ""):gsub("/", "-")
  return "/tmp/radish-nvim-" .. safe_name .. ".sock"
end

-- MCP JSON-RPC message handling
local function create_response(id, result)
  return vim.json.encode({
    jsonrpc = "2.0",
    id = id,
    result = result
  })
end

local function create_error_response(id, code, message)
  return vim.json.encode({
    jsonrpc = "2.0",
    id = id,
    error = {
      code = code,
      message = message
    }
  })
end

-- MCP Protocol handlers
local handlers = {}

-- Initialize handler
handlers["initialize"] = function(params)
  return {
    protocolVersion = "2024-11-05",
    capabilities = {
      tools = vim.empty_dict(),
      resources = vim.empty_dict(),
      prompts = vim.empty_dict()
    },
    serverInfo = {
      name = "radish-neovim-server",
      version = "0.1.0"
    }
  }
end

-- List tools handler
handlers["tools/list"] = function(params)
  return {
    tools = {
      {
        name = "vim_buffer",
        description = "Get buffer contents with line numbers",
        inputSchema = {
          type = "object",
          properties = {
            filename = {
              type = "string",
              description = "Optional filename to view specific buffer"
            }
          }
        }
      },
      {
        name = "vim_status",
        description = "Get comprehensive Neovim status",
        inputSchema = {
          type = "object",
          properties = vim.empty_dict()
        }
      },
      {
        name = "vim_command",
        description = "Execute vim command",
        inputSchema = {
          type = "object",
          properties = {
            command = {
              type = "string",
              description = "Vim command to execute"
            }
          },
          required = {"command"}
        }
      },
      {
        name = "vim_preview_change",
        description = "Preview changes to a file before applying",
        inputSchema = {
          type = "object",
          properties = {
            file = {
              type = "string",
              description = "File path to preview changes for"
            },
            changes = {
              type = "string",
              description = "Content changes to preview"
            },
            mode = {
              type = "string",
              enum = {"inline", "split", "float"},
              description = "How to display the preview"
            }
          },
          required = {"file", "changes"}
        }
      }
    }
  }
end

-- Tool execution handlers
local tool_handlers = {}

tool_handlers["vim_buffer"] = function(arguments)
  local filename = arguments.filename
  local bufnr = vim.fn.bufnr(filename or "%")

  if bufnr == -1 then
    return {
      content = {
        {
          type = "text",
          text = "Buffer not found: " .. (filename or "current")
        }
      }
    }
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local numbered_lines = {}

  for i, line in ipairs(lines) do
    table.insert(numbered_lines, string.format("%d: %s", i, line))
  end

  return {
    content = {
      {
        type = "text",
        text = table.concat(numbered_lines, "\n")
      }
    }
  }
end

tool_handlers["vim_status"] = function(arguments)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local mode = vim.api.nvim_get_mode().mode
  local filename = vim.api.nvim_buf_get_name(0)
  local cwd = vim.fn.getcwd()

  local status = {
    cursorPosition = cursor,
    mode = mode,
    fileName = filename,
    cwd = cwd,
    buffers = #vim.api.nvim_list_bufs()
  }

  return {
    content = {
      {
        type = "text",
        text = vim.json.encode(status)
      }
    }
  }
end

tool_handlers["vim_command"] = function(arguments)
  local command = arguments.command

  if not command then
    return {
      content = {
        {
          type = "text",
          text = "Error: command parameter required"
        }
      }
    }
  end

  local success, result = pcall(vim.cmd, command)

  if success then
    return {
      content = {
        {
          type = "text",
          text = "Command executed: " .. command
        }
      }
    }
  else
    return {
      content = {
        {
          type = "text",
          text = "Error executing command: " .. tostring(result)
        }
      }
    }
  end
end

tool_handlers["vim_preview_change"] = function(arguments)
  -- TODO: Implement preview window functionality
  return {
    content = {
      {
        type = "text",
        text = "Preview functionality coming soon!"
      }
    }
  }
end

-- Handle tools/call
handlers["tools/call"] = function(params)
  local tool_name = params.name
  local arguments = params.arguments or {}

  local handler = tool_handlers[tool_name]
  if not handler then
    error("Unknown tool: " .. tool_name)
  end

  return handler(arguments)
end

-- Process incoming MCP message
local function process_message(msg_str)
  local ok, msg = pcall(vim.json.decode, msg_str)

  if not ok then
    return create_error_response(nil, -32700, "Parse error: " .. tostring(msg))
  end

  -- Handle JSON-RPC request
  if msg.method then
    local handler = handlers[msg.method]

    if not handler then
      return create_error_response(msg.id, -32601, "Method not found: " .. msg.method)
    end

    local ok, result = pcall(handler, msg.params or {})

    if ok then
      return create_response(msg.id, result)
    else
      return create_error_response(msg.id, -32603, "Internal error: " .. tostring(result))
    end
  end

  return create_error_response(msg.id, -32600, "Invalid Request")
end

-- Start MCP server on Unix socket
function M.start_server()
  local socket_path = get_socket_path()

  -- Remove existing socket file if it exists
  if vim.fn.filereadable(socket_path) == 1 then
    vim.fn.delete(socket_path)
  end

  -- Create Unix socket server using vim.loop (libuv)
  local server = vim.loop.new_pipe(false)

  local ok, err = pcall(function()
    server:bind(socket_path)
  end)

  if not ok then
    vim.notify("Radish MCP: Failed to bind socket: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  server:listen(128, function(listen_err)
    if listen_err then
      vim.notify("Radish MCP: Listen error: " .. tostring(listen_err), vim.log.levels.ERROR)
      return
    end

    -- Accept client connection
    local client = vim.loop.new_pipe(false)
    server:accept(client)

    vim.notify("Radish MCP: Client connected!", vim.log.levels.INFO)

    -- Buffer for incomplete messages
    local buffer = ""

    -- Read from client
    client:read_start(function(read_err, chunk)
      if read_err then
        vim.schedule(function()
          vim.notify("Radish MCP: Client read error: " .. tostring(read_err), vim.log.levels.ERROR)
        end)
        client:close()
        return
      end

      if chunk then
        buffer = buffer .. chunk

        -- Process complete JSON-RPC messages (newline-delimited)
        while buffer:find("\n") do
          local newline_pos = buffer:find("\n")
          local msg = buffer:sub(1, newline_pos - 1)
          buffer = buffer:sub(newline_pos + 1)

          -- Process message in vim context
          vim.schedule(function()
            local response = process_message(msg)
            if response then
              client:write(response .. "\n")
            end
          end)
        end
      else
        -- Client disconnected
        vim.schedule(function()
          vim.notify("Radish MCP: Client disconnected", vim.log.levels.INFO)
        end)
        client:close()
      end
    end)
  end)

  -- Store server reference
  M.server = server
  M.socket_path = socket_path

  vim.notify("Radish MCP server listening on: " .. socket_path, vim.log.levels.INFO)

  -- Cleanup on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      if server and not server:is_closing() then
        server:close()
      end
      vim.fn.delete(socket_path)
    end
  })
end

-- Setup function for plugin configuration
function M.setup(opts)
  opts = opts or {}

  -- Auto-start server
  if opts.auto_start ~= false then
    vim.defer_fn(function()
      M.start_server()
    end, 100)
  end
end

return M
