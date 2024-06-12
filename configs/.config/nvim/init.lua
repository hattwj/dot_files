-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Eager load vimscripts from ~/.config/nvim/plugin/
local plugin_dir = vim.fn.stdpath("config") .. "/plugin"
vim.cmd("runtime! " .. plugin_dir .. "/*.vim")
