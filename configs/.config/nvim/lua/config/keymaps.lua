-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map Control arrow L/R to prev next buffer
vim.api.nvim_set_keymap("n", "<C-Left>", ":BufferLineCyclePrev<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-Right>", ":BufferLineCycleNext<CR>", { noremap = true })

-- Close current buffer -- already default
vim.api.nvim_set_keymap("n", "<leader>c", ":bd<CR>", { noremap = true, desc = "Close current buffer" })

-- Open a file browser in the parent of the current file
-- vim.api.nvim_set_keymap("n", "-", ":Neotree position=float<CR>", { noremap = true })
vim.api.nvim_set_option_value("clipboard", "unnamed", {})

vim.api.nvim_set_keymap("n", "<F2>", ":mksession! ~/.vim_session <CR>", { desc = "create session" }) -- Quick write session with F2
vim.api.nvim_set_keymap("n", "<F3>", ":mksession! ~/.vim_session <CR>", { desc = "load session" }) -- And load session with F3

-- Grep search in telescope
vim.api.nvim_set_keymap("n", "<leader>fa", ":Telescope live_grep<CR>", {})
