-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Set the default shell to bash
vim.api.nvim_set_option_value("shell", "/usr/bin/bash", {})

-- " vim managed pastes
vim.api.nvim_set_option_value("paste", false, {})

-- " use system clipboard by default
vim.api.nvim_set_option_value("clipboard", "unnamed", {})

-- enable mouse support
vim.api.nvim_set_option_value("mouse", "a", {})

-- Allow case insensitive tab completion on the command ":" bar
vim.api.nvim_set_option_value("wildignorecase", true, {})

-- Set clipboard for vim to allow copy paste
vim.api.nvim_set_option_value("clipboard", "unnamed", {})

-- Enable spell checker
vim.opt.spell = true

-- Default to not concealing any text, this can happen in markdown
-- files using nested source code, the ```<format> lines are hidden from view.
vim.api.nvim_set_option_value("conceallevel", 0, {})
