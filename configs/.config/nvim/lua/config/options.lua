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
-- Make double sure that tab completion works without case sensitivity, sometimes it wasn't working
vim.opt.ignorecase = true

-- Set clipboard for vim to allow copy paste
vim.api.nvim_set_option_value("clipboard", "unnamed", {})

-- Enable spell checker
vim.opt.spell = true

-- Default to not concealing any text, this can happen in markdown
-- files using nested source code, the ```<format> lines are hidden from view.
vim.api.nvim_set_option_value("conceallevel", 0, {})

-- Do not autoformat files
vim.g.autoformat = false

-- Set relative line numbers
vim.api.nvim_set_option_value('number', true, {})
vim.api.nvim_set_option_value('relativenumber', true , {})

vim.cmd("highlight WinSeparator guifg=orange")

-- Enable python LSP using pyright
vim.g.lazyvim_python_lsp = "pyright"

-- Set line wrap when using arrows.
-- - Hitting right arrow at end of the
--   line should jump to the next line.
vim.cmd("set whichwrap+=<,>,h,l,[,]")

-- Fix compatibility issue between BufferLine plugin and netrw. BufferLine 
-- would refuse to cycle through buffers when netrw was being used.
vim.cmd("let g:netrw_bufsettings = 'noma nomod nonu nowrap ro buflisted'")

-- Set line length markers at 80 and 120 characters
vim.api.nvim_set_option_value('colorcolumn', '80,120', {})
