-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Disable linting diagnostic messages for markdown
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = false
    vim.diagnostic.enable(false)  -- 0 means current buffer
  end,
})


-- When entering Insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    -- disable inlay hints
    -- Inlay hints are the class and type hints you get in strictly typed languages
    -- from the LSP. When they are present it is very difficult to type and keep
    -- track of where the cursor is.
    vim.lsp.inlay_hint.enable(false)
  end,
})

-- when leaving Insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    -- Re-enable inlay hints
    vim.lsp.inlay_hint.enable(true)
  end,
})

-- Terminal autocommands
vim.api.nvim_command("autocmd TermOpen * startinsert")             -- starts in insert mode
vim.api.nvim_command("autocmd TermOpen * setlocal nonumber norelativenumber")       -- no numbers
vim.api.nvim_command("autocmd TermEnter * setlocal signcolumn=no") -- no sign column

-- Open the dashboard for new tabs.
-- TODO: This will also trigger the dashboard when `:tabnew filename.txt` is used. Make it not do that.
vim.api.nvim_create_autocmd("TabNewEntered", {
  command = "lua Snacks.dashboard()",
})
