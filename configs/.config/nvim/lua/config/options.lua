-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Set the default shell to bash
vim.api.nvim_set_option_value("shell", "/usr/bin/bash", {})

-- " vim managed pastes
vim.api.nvim_set_option_value("paste", false, {})

-- " use system clipboard by default
vim.api.nvim_set_option_value("clipboard", "unnamed", {})

vim.api.nvim_set_option_value("mouse", "a", {})
