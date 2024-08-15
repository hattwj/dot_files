-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Eager load vimscripts from ~/.config/nvim/plugins/
vim.cmd('so' .. vim.fn.stdpath("config") .. "/lua/plugins/vim-snippets.vim")
