-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map Control arrow L/R to prev next buffer
vim.api.nvim_set_keymap("n", "<C-Left>", ":BufferLineCyclePrev<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-Right>", ":BufferLineCycleNext<CR>", { silent = true, noremap = true })

-- Map leader arrow to move tabs
vim.api.nvim_set_keymap("n", "<leader><Left>", ":tabp<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<leader><Right>", ":tabn<CR>", { silent = true, noremap = true })

-- Simple session management
vim.api.nvim_set_keymap("n", "<F2>", ":mksession! ~/.vim_session <CR>", { desc = "create session" }) -- Quick write session with F2
vim.api.nvim_set_keymap("n", "<F3>", ":mksession! ~/.vim_session <CR>", { desc = "load session" }) -- And load session with F3

-- Grep search in telescope
vim.api.nvim_set_keymap("n", "<leader>fa", ":Telescope live_grep<CR>", { desc = "live_grep" })

-- Toggle code comments
vim.api.nvim_set_keymap("n", "<leader>-", "gcc",{ desc="Toggle code comment", noremap=false})
vim.api.nvim_set_keymap("v", "<leader>-", "gc",{ desc="Toggle code comment", noremap=false})
vim.api.nvim_set_keymap("v", "-", "gc",{ desc="Toggle code comment", noremap=false})

-- Find files without git
vim.api.nvim_set_keymap(
  "n",
  "<leader>ff",
  ":Telescope find_files<CR>",
  { silent = true, noremap = true, desc = "Find files (without git)" }
)

vim.api.nvim_set_keymap('n', '<leader>fw', ":lua require'telescope.builtin'.grep_string()<CR>", {silent=true, desc='Find word under cursor'})

vim.api.nvim_set_keymap(
  "n",
  "<leader>fc",
  ":Telescope git_commits<CR>",
  { silent = true, noremap = true, desc = "Find git commits" }
 )
vim.api.nvim_set_keymap(
  "n",
  "<leader>fk",
  "<leader>sk",
  { silent = true, noremap = false, desc = "Find key maps" }
 )
vim.api.nvim_set_keymap(
  "n",
  "<leader>fC",
  "<leader>sC",
  { silent = true, noremap = false, desc = "Find vim commands" }
 )

-- Close / delete the current buffer
vim.api.nvim_set_keymap("n", "<leader>q", "<leader>bd", { silent = true, desc="Close current buffer" })

-- Open file finder in current file directory, select current file
vim.api.nvim_set_keymap("n", "-", ":Neotree reveal_force_cwd %:p<CR>", { silent = true, desc="Open finder here" })

-- Disable diagnostics
vim.api.nvim_set_keymap("n", "<leader>xd", ":lua vim.diagnostic.disable()<CR>", { silent = true, desc="Disable diagnostics" })
vim.api.nvim_set_keymap("n", "<leader>xD", ":lua vim.diagnostic.enable()<CR>", { silent = true, desc="Enable diagnostics" })
-- Toggle autofix
vim.api.nvim_set_keymap("n", "<leader>xa", ":lua vim.b.autoformat = false<CR>", { silent = true, desc="Disable autoformat" })
vim.api.nvim_set_keymap("n", "<leader>xA", ":lua vim.b.autoformat = true<CR>", { silent = true, desc="Enable autoformat" })

vim.cmd([[
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " => Copy Paste Settings
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  
  " map CTRL-E to end-of-line (insert and normal mode)
  imap <C-e> <esc>$i<right>
  nmap <C-e> $
  vmap <C-e> $
  
  " map CTRL-A to beginning-of-line (insert and normal mode)
  imap <C-a> <esc>0i
  nmap <C-e> 0
  
  " Map Shift-A to select all text
  nmap A ggVG
  
  " CTRL-C to copy (visual mode)
  " vmap <C-c> "+y
  "<Ctrl-C> -- copy (goto visual mode and copy)
  imap <C-C> <C-O>vgG
  vmap <C-c> "+y
  
  " CTRL-X to cut (visual mode)
  vmap <C-x> xi
  
  " CTRL-V to paste (insert and visual mode)
  imap <C-v> <esc>Pi
  vmap <C-v> <esc>Pi
]])

-- Open a file browser in the parent of the current file
--
