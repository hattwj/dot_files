-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map Control arrow L/R to prev next buffer
vim.api.nvim_set_keymap("n", "<C-Left>", ":BufferLineCyclePrev<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<C-Right>", ":BufferLineCycleNext<CR>", { noremap = true })

-- Close current buffer -- already default
vim.api.nvim_set_keymap("n", "<leader>c", ":bd<CR>", { noremap = true, desc = "Close current buffer" })

-- Set clipboard for vim
vim.api.nvim_set_option_value("clipboard", "unnamedplus", {})

vim.api.nvim_set_keymap("n", "<F2>", ":mksession! ~/.vim_session <CR>", { desc = "create session" }) -- Quick write session with F2
vim.api.nvim_set_keymap("n", "<F3>", ":mksession! ~/.vim_session <CR>", { desc = "load session" }) -- And load session with F3

-- Grep search in telescope
vim.api.nvim_set_keymap("n", "<C-p>", ":Telescope git_files<CR>", { desc = "git_files search" })
vim.api.nvim_set_keymap("n", "<leader>fa", ":Telescope live_grep<CR>", { desc = "grep search" })
vim.api.nvim_set_keymap(
  "n",
  "<leader>fc",
  ":Telescope git_commits<CR>",
  { noremap = true, desc = "search git commits" }
)

-- Code comment toggle with "-" key in normal mode
vim.api.nvim_set_keymap("n", "<leader>-", ":normal gcc<CR>", { desc = "[-] toggle comment" })
vim.api.nvim_set_keymap("v", "<leader>-", "<Esc>:normal gvgc<CR>", { desc = "[-] toggle comment block" })
