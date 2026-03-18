-- vim_buffers_list tool - list all buffers with metadata
local M = {}

M.schema = {
  name = "vim_buffers_list",
  description = "List all buffers with metadata (name, loaded, modified, filetype). Useful for discovering what files are open in Neovim.",
  inputSchema = {
    type = "object",
    properties = {
      filter = {
        type = "string",
        enum = {"all", "loaded", "listed", "modified"},
        description = "Filter buffers (default: listed)"
      }
    }
  }
}

M.handler = function(arguments)
  local filter = arguments.filter or "listed"
  local bufs = vim.api.nvim_list_bufs()
  local results = {}

  for _, bufnr in ipairs(bufs) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    local loaded = vim.api.nvim_buf_is_loaded(bufnr)
    local listed = vim.bo[bufnr].buflisted
    local modified = loaded and vim.bo[bufnr].modified or false
    local filetype = loaded and vim.bo[bufnr].filetype or ""

    -- Apply filter
    local include = false
    if filter == "all" then
      include = true
    elseif filter == "loaded" then
      include = loaded
    elseif filter == "listed" then
      include = listed
    elseif filter == "modified" then
      include = modified
    end

    if include then
      local flags = {}
      if modified then table.insert(flags, "+") end
      if not listed then table.insert(flags, "u") end
      if bufnr == vim.api.nvim_get_current_buf() then table.insert(flags, "%") end

      table.insert(results, {
        nr = bufnr,
        name = name ~= "" and name or "[No Name]",
        flags = table.concat(flags),
        filetype = filetype,
      })
    end
  end

  if #results == 0 then
    return {
      content = {{ type = "text", text = "No buffers match filter: " .. filter }}
    }
  end

  local lines = {}
  for _, buf in ipairs(results) do
    local ft = buf.filetype ~= "" and (" [" .. buf.filetype .. "]") or ""
    table.insert(lines, string.format(
      "%3d %s %s%s",
      buf.nr, buf.flags, buf.name, ft
    ))
  end

  return {
    content = {{ type = "text", text = table.concat(lines, "\n") }}
  }
end

return M
