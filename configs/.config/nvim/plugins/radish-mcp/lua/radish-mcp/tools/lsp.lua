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

M.handler = function(arguments)
  local file = arguments.file
  local request_type = arguments.request_type or "diagnostics"
  local line = arguments.line
  local col = arguments.col

  -- Get buffer number
  local bufnr
  if file then
    bufnr = vim.fn.bufnr(file)
    if bufnr == -1 then
      return {
        content = {
          {
            type = "text",
            text = "Error: Buffer not found for file: " .. file
          }
        }
      }
    end
  else
    bufnr = vim.api.nvim_get_current_buf()
  end

  -- Handle different request types
  if request_type == "diagnostics" then
    local diagnostics = vim.diagnostic.get(bufnr)

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

    -- Request document symbols from first client
    local client = clients[1]
    local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

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
