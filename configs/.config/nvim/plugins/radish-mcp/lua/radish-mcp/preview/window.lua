-- Preview window for inline diff view with virtual text
local state = require("radish-mcp.state")
local M = {}

-- Namespace for virtual text and highlights
M.ns_id = vim.api.nvim_create_namespace("radish_preview")

-- Highlight groups for inline diff
local function setup_highlights()
  vim.api.nvim_set_hl(0, "RadishAddition", {
    bg = "#3a3a00",
    fg = "#ffffff"
  })

  vim.api.nvim_set_hl(0, "RadishDeletion", {
    bg = "#3a0000",
    fg = "#888888"
  })

  vim.api.nvim_set_hl(0, "RadishVirtualAdd", {
    fg = "#ffff00",
    italic = true
  })

  vim.api.nvim_set_hl(0, "RadishVirtualDel", {
    fg = "#ff0000",
    italic = true,
    strikethrough = true
  })
end

setup_highlights()

-- Compute diff between current and new content
local function compute_diff(current_lines, new_lines)
  local changes = {}
  local max_len = math.max(#current_lines, #new_lines)

  for i = 1, max_len do
    local curr = current_lines[i]
    local new = new_lines[i]

    if curr and not new then
      table.insert(changes, { type = "delete", line = i, old_content = curr })
    elseif new and not curr then
      table.insert(changes, { type = "add", line = i, new_content = new })
    elseif curr ~= new then
      table.insert(changes, { type = "modify", line = i, old_content = curr, new_content = new })
    end
  end

  return changes
end

-- Open inline diff preview
function M.open(file, changes, mode)
  M.close()

  state.preview.file = file
  state.preview.changes = changes
  state.preview.status = "pending"
  state.preview.is_open = true

  vim.schedule(function()
    local exists = vim.fn.filereadable(file) == 1
    local current_lines = {}

    if exists then
      current_lines = vim.fn.readfile(file)
    end

    local new_lines = vim.split(changes, "\n", { plain = true })

    local bufnr
    if exists then
      vim.cmd("edit " .. vim.fn.fnameescape(file))
      bufnr = vim.api.nvim_get_current_buf()
    else
      vim.cmd("enew")
      bufnr = vim.api.nvim_get_current_buf()
      vim.api.nvim_buf_set_name(bufnr, file)
      vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
    end

    state.preview.bufnr = bufnr
    vim.api.nvim_buf_set_option(bufnr, "modifiable", true)

    local diff = compute_diff(current_lines, new_lines)

    for _, change in ipairs(diff) do
      local line_idx = change.line - 1

      if change.type == "delete" then
        if line_idx < vim.api.nvim_buf_line_count(bufnr) then
          vim.api.nvim_buf_add_highlight(bufnr, M.ns_id, "RadishDeletion", line_idx, 0, -1)
          vim.api.nvim_buf_set_extmark(bufnr, M.ns_id, line_idx, 0, {
            virt_text = {{ " [DELETED]", "RadishVirtualDel" }},
            virt_text_pos = "eol"
          })
        end
      elseif change.type == "add" then
        local insert_line = line_idx
        if insert_line > vim.api.nvim_buf_line_count(bufnr) then
          insert_line = vim.api.nvim_buf_line_count(bufnr)
        end
        vim.api.nvim_buf_set_extmark(bufnr, M.ns_id, insert_line, 0, {
          virt_lines = {{{ change.new_content, "RadishAddition" }}},
          virt_lines_above = true
        })
      elseif change.type == "modify" then
        vim.api.nvim_buf_add_highlight(bufnr, M.ns_id, "RadishDeletion", line_idx, 0, -1)
        vim.api.nvim_buf_set_extmark(bufnr, M.ns_id, line_idx, 0, {
          virt_lines = {{{ change.new_content, "RadishAddition" }}},
          virt_lines_above = false
        })
      end
    end

    vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
    vim.api.nvim_buf_set_option(bufnr, "modified", false)

    local opts = { buffer = bufnr, noremap = true, silent = true }
    vim.keymap.set('n', 'a', function() M.accept() end, opts)
    vim.keymap.set('n', 'r', function() M.reject() end, opts)
    vim.keymap.set('n', 'q', function() M.close() end, opts)

    vim.notify("Preview: 'a' to accept, 'r' to reject, 'q' to close", vim.log.levels.INFO)
  end)

  return "Preview opened for: " .. file .. "\nUse 'a' to accept, 'r' to reject, 'q' to close"
end

function M.close()
  if state.preview.bufnr then
    if vim.api.nvim_buf_is_valid(state.preview.bufnr) then
      vim.api.nvim_buf_clear_namespace(state.preview.bufnr, M.ns_id, 0, -1)
      pcall(vim.keymap.del, 'n', 'a', { buffer = state.preview.bufnr })
      pcall(vim.keymap.del, 'n', 'r', { buffer = state.preview.bufnr })
      pcall(vim.keymap.del, 'n', 'q', { buffer = state.preview.bufnr })
      pcall(vim.api.nvim_buf_set_option, state.preview.bufnr, "modifiable", true)
    end
  end

  state.preview.file = nil
  state.preview.changes = nil
  state.preview.status = "none"
  state.preview.is_open = false
  state.preview.bufnr = nil
  state.preview.result_message = nil
end

function M.accept()
  if not state.preview.file or not state.preview.changes then
    return
  end

  local lines = vim.split(state.preview.changes, "\n", { plain = true })
  vim.fn.writefile(lines, state.preview.file)

  local bufnr = vim.fn.bufnr(state.preview.file)
  if bufnr ~= -1 then
    vim.api.nvim_buf_clear_namespace(bufnr, M.ns_id, 0, -1)
    vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("edit!")
    end)
  end

  local msg = "Changes accepted for: " .. state.preview.file
  vim.notify(msg, vim.log.levels.INFO)
  state.preview.status = "accepted"
  state.preview.result_message = msg
end

function M.reject()
  if not state.preview.file then
    return
  end

  local msg = "Changes rejected for: " .. state.preview.file
  vim.notify(msg, vim.log.levels.INFO)
  state.preview.status = "rejected"
  state.preview.result_message = msg
end

function M.create_buffer(file, changes)
  return nil, nil
end

return M
