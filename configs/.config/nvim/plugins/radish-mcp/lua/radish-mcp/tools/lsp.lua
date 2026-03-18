-- LSP metadata tool
local M = {}

M.schema = {
  name = "vim_lsp_request",
  description = "Get LSP metadata for a buffer (diagnostics, symbols, hover info, etc)",
  inputSchema = {
    type = "object",
    properties = {
      file = {
        type = "string",
        description = "Optional file path, defaults to current buffer"
      },
      request_type = {
        type = "string",
        enum = {"diagnostics", "symbols", "hover", "definition", "references"},
        description = "Type of LSP information to retrieve (default: diagnostics)"
      },
      line = {
        type = "number",
        description = "Line number for position-specific requests (hover, definition, references)"
      },
      col = {
        type = "number",
        description = "Column number for position-specific requests"
      }
    }
  }
}

-- Config for LSP diagnostics
local MAX_FILE_SIZE = 1024 * 1024  -- 1MB max
local BINARY_CHECK_BYTES = 8192    -- Check first 8KB for binary content

-- Helper: Get or load buffer for filepath (without changing active buffer)
-- Returns: bufnr, error, was_newly_loaded
local function get_or_load_buffer(filepath)
  if not filepath or filepath == "" then
    return nil, "No filepath provided", false
  end

  -- Normalize path
  filepath = vim.fn.fnamemodify(filepath, ":p")

  -- Check if already loaded in a buffer
  local bufnr = vim.fn.bufnr(filepath)
  if bufnr ~= -1 then
    return bufnr, nil, false  -- Already loaded
  end

  -- Check if file exists
  if vim.fn.filereadable(filepath) ~= 1 then
    return nil, "File not found: " .. filepath, false
  end

  -- Check file size (skip very large files)
  local stat = vim.loop.fs_stat(filepath)
  if stat and stat.size > MAX_FILE_SIZE then
    return nil, string.format("File too large (%d bytes, max %d)", stat.size, MAX_FILE_SIZE), false
  end

  -- Check for binary content (null bytes in first chunk)
  local fd = vim.loop.fs_open(filepath, "r", 438)
  if fd then
    local chunk = vim.loop.fs_read(fd, BINARY_CHECK_BYTES, 0)
    vim.loop.fs_close(fd)
    if chunk and chunk:find("\0") then
      return nil, "Binary file detected", false
    end
  end

  -- Load the file into a hidden buffer (does NOT change active buffer)
  bufnr = vim.fn.bufadd(filepath)
  if bufnr == 0 then
    return nil, "Failed to add buffer for: " .. filepath, false
  end

  -- Load buffer content, suppressing swap file prompts entirely:
  -- noswapfile: prevents creating a NEW swap file
  -- shortmess+=A: suppresses E325 ATTENTION prompt from EXISTING swap files
  local saved_shortmess = vim.o.shortmess
  vim.o.shortmess = saved_shortmess .. "A"
  vim.cmd("noswapfile call bufload(" .. bufnr .. ")")
  vim.o.shortmess = saved_shortmess
  vim.bo[bufnr].swapfile = false

  -- Trigger filetype detection (needed for LSP to attach)
  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("filetype detect")
  end)

  return bufnr, nil, true  -- Newly loaded
end

-- Helper: Check if any LSP client supports a given method for a buffer
local function any_client_supports(clients, method, bufnr)
  for _, client in ipairs(clients) do
    if client.supports_method(method, { bufnr = bufnr }) then
      return true
    end
  end
  return false
end

-- Helper: Wait for LSP to attach and provide diagnostics (for newly loaded buffers)
-- Uses blocking LSP request to ensure server has processed the file
-- Returns: diagnostics, debug_info
local function wait_for_lsp(bufnr, max_wait_ms, interval_ms, filepath)
  max_wait_ms = max_wait_ms or 20000
  interval_ms = interval_ms or 100

  local debug_info = {
    filepath = filepath,
    bufnr = bufnr,
    filetype = vim.bo[bufnr].filetype,
    checks = 0,
    lsp_clients_initial = #vim.lsp.get_clients({ bufnr = bufnr }),
  }

  -- If we already have diagnostics, return immediately
  local diagnostics = vim.diagnostic.get(bufnr)
  if #diagnostics > 0 then
    debug_info.result = "immediate"
    return diagnostics, debug_info
  end

  -- Wait for LSP client to attach
  local elapsed = 0
  while elapsed < max_wait_ms do
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    debug_info.checks = debug_info.checks + 1

    if #clients > 0 then
      -- LSP attached! Force server to process the file
      -- Only use documentSymbol if a client supports it, otherwise just poll
      local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

      if any_client_supports(clients, "textDocument/documentSymbol", bufnr) then
        vim.lsp.buf_request_sync(bufnr, "textDocument/documentSymbol", params, 5000)
        debug_info.sync_method = "documentSymbol"
      else
        -- No client supports documentSymbol; wait briefly for diagnostics
        vim.wait(500, function() return #vim.diagnostic.get(bufnr) > 0 end)
        debug_info.sync_method = "poll"
      end

      -- Diagnostics arrive asynchronously; poll briefly after sync
      vim.wait(2000, function() return #vim.diagnostic.get(bufnr) > 0 end)
      diagnostics = vim.diagnostic.get(bufnr)
      debug_info.result = "after_sync_" .. elapsed .. "ms"
      debug_info.lsp_clients_final = #clients
      return diagnostics, debug_info
    end

    vim.wait(interval_ms, function() return false end)
    elapsed = elapsed + interval_ms
  end

  debug_info.result = "timeout"
  debug_info.lsp_clients_final = #vim.lsp.get_clients({ bufnr = bufnr })
  return vim.diagnostic.get(bufnr), debug_info
end

M.handler = function(arguments)
  local file = arguments.file
  local request_type = arguments.request_type or "diagnostics"
  local line = arguments.line
  local col = arguments.col

  -- Get or load buffer (auto-loads if not already open)
  local bufnr
  local was_newly_loaded = false
  if file then
    local err
    bufnr, err, was_newly_loaded = get_or_load_buffer(file)
    if not bufnr then
      return {
        content = {
          {
            type = "text",
            text = "Error: " .. (err or "Unknown error loading buffer")
          }
        }
      }
    end
  else
    bufnr = vim.api.nvim_get_current_buf()
  end

  -- Handle different request types
  if request_type == "diagnostics" then
    local diagnostics
    local debug_info

    if was_newly_loaded then
      -- Buffer was just loaded, wait for LSP to attach (up to 20s, check every 100ms)
      diagnostics, debug_info = wait_for_lsp(bufnr, 20000, 100, file)
    else
      diagnostics = vim.diagnostic.get(bufnr)
    end

    local formatted = {}
    for _, diag in ipairs(diagnostics) do
      local severity = vim.diagnostic.severity[diag.severity]
      table.insert(formatted, string.format(
        "[%s] Line %d, Col %d: %s",
        severity,
        diag.lnum + 1,
        diag.col + 1,
        diag.message
      ))
    end

    if #formatted == 0 then
      -- Include debug info when no diagnostics found for newly loaded buffer
      if debug_info then
        table.insert(formatted, string.format(
          "DEBUG: filetype=%s, lsp_initial=%d, lsp_final=%d, checks=%d, result=%s",
          debug_info.filetype or "nil", debug_info.lsp_clients_initial or 0,
          debug_info.lsp_clients_final or 0, debug_info.checks or 0, debug_info.result or "unknown"))
      end
      table.insert(formatted, "No diagnostics found")
    end

    return {
      content = {
        {
          type = "text",
          text = table.concat(formatted, "\n")
        }
      }
    }

  elseif request_type == "symbols" then
    -- Get document symbols
    if was_newly_loaded then
      -- Wait for LSP to attach before requesting symbols
      wait_for_lsp(bufnr, 20000, 100, file)
    end

    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    if #clients == 0 then
      return {
        content = {
          {
            type = "text",
            text = "No LSP client attached to buffer"
          }
        }
      }
    end

    local symbols = {}

    -- Request document symbols from first client that supports it
    local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
    for _, client in ipairs(clients) do
      if client.supports_method("textDocument/documentSymbol", { bufnr = bufnr }) then
        local result = client.request_sync('textDocument/documentSymbol', params, 5000, bufnr)

        if result and result.result then
          for _, symbol in ipairs(result.result) do
            table.insert(symbols, string.format(
              "%s %s (Line %d)",
              symbol.kind,
              symbol.name,
              symbol.range.start.line + 1
            ))
          end
        end
        break
      end
    end

    if #symbols == 0 then
      table.insert(symbols, "No symbols found")
    end

    return {
      content = {
        {
          type = "text",
          text = table.concat(symbols, "\n")
        }
      }
    }

  elseif request_type == "hover" then
    if not line or not col then
      return {
        content = {
          {
            type = "text",
            text = "Error: line and col required for hover requests"
          }
        }
      }
    end

    if was_newly_loaded then
      -- Wait for LSP to attach before requesting hover
      wait_for_lsp(bufnr, 20000, 100, file)
    end

    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if #clients == 0 then
      return {
        content = {
          {
            type = "text",
            text = "No LSP client attached"
          }
        }
      }
    end

    local client = clients[1]
    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    params.position.line = line - 1  -- LSP is 0-indexed
    params.position.character = col - 1

    local result = clients[1].request_sync('textDocument/hover', params, 5000, bufnr)

    if result and result.result and result.result.contents then
      local contents = result.result.contents
      local text = ""

      if type(contents) == "string" then
        text = contents
      elseif contents.value then
        text = contents.value
      end

      return {
        content = {
          {
            type = "text",
            text = text or "No hover information"
          }
        }
      }
    end

    return {
      content = {
        {
          type = "text",
          text = "No hover information available"
        }
      }
    }
  else
    return {
      content = {
        {
          type = "text",
          text = "Request type not yet implemented: " .. request_type
        }
      }
    }
  end
end

return M
