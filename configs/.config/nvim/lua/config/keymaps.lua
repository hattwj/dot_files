-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set:
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map page up down to use <C-U> <C-D>, that way, when we page up it goes to the first line of the file
-- - Otherwise it will stop when the 1st line scrolls into view, rather than adjusting the current line.
vim.api.nvim_set_keymap('n', '<PageUp>', '<C-U>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<PageDown>', '<C-D>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<PageUp>', '<C-U>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<PageDown>', '<C-D>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<PageUp>', '<C-O><C-U>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<PageDown>', '<C-O><C-D>', { noremap = true, silent = true })

-- Map Control arrow L/R to prev next buffer
vim.api.nvim_set_keymap("n", "<C-Left>", ":BufferLineCyclePrev<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-Right>", ":BufferLineCycleNext<CR>", { silent = true, noremap = true })

-- Map leader arrow to move tabs
vim.keymap.set({"n"}, "<leader><Left>", ":tabp<CR>", { silent = true, noremap = true })
vim.keymap.set({"n"}, "<leader><Right>", ":tabn<CR>", { silent = true, noremap = true })

-- Simple session management
vim.api.nvim_set_keymap("n", "<F2>", ":mksession! ~/.vim_session <CR>", { desc = "create session" }) -- Quick write session with F2
vim.api.nvim_set_keymap("n", "<F3>", ":mksession! ~/.vim_session <CR>", { desc = "load session" }) -- And load session with F3

-- Grep search in telescope
vim.api.nvim_set_keymap("n", "<leader>fa", ":ProjectRoot2<CR>:Telescope live_grep<CR>", { desc = "live_grep" })

-- List projects
vim.api.nvim_set_keymap("n", "<C-p>", ":Telescope projects<CR>", { desc = "live_grep" })

-- Toggle code comments
vim.api.nvim_set_keymap("n", "<leader>-", "gcc",{ desc="Toggle code comment", noremap=false})
vim.api.nvim_set_keymap("v", "<leader>-", "gc",{ desc="Toggle code comment", noremap=false})
vim.api.nvim_set_keymap("v", "-", "gc",{ desc="Toggle code comment", noremap=false})

-- Find files without git
vim.api.nvim_set_keymap(
  "n",
  "<leader>ff",
  ":ProjectRoot2<CR>:Telescope find_files<CR>",
  { silent = true, noremap = true, desc = "Find files (without git)" }
)

vim.api.nvim_set_keymap(
  'n',
  '<leader>fw',
  ":ProjectRoot2<CR>:lua require'telescope.builtin'.grep_string()<CR>",
  {silent=true, desc='Find word under cursor'}
)

vim.api.nvim_set_keymap(
  "n",
  "<leader>fg",
  ":ProjectRoot2<CR>:Telescope git_status<CR>",
  { silent = true, noremap = true, desc = "Git status" }
)

vim.api.nvim_set_keymap(
  "n",
  "<leader>fc",
  ":ProjectRoot2<CR>:Telescope git_commits<CR>",
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

-- Show keybindings
vim.api.nvim_set_keymap("n", "<leader>k", ":WhichKey<CR>", { silent = true, desc="Show keybindings" })

-- Open file finder in current file directory, select current file
vim.api.nvim_set_keymap("n", "-", ":Explore %:p:h<CR>", { silent = true, desc="Open finder here" })

-- Disable diagnostics
vim.api.nvim_set_keymap("n", "<leader>xd", ":lua vim.diagnostic.disable()<CR>", { silent = true, desc="Disable diagnostics" })
vim.api.nvim_set_keymap("n", "<leader>xD", ":lua vim.diagnostic.enable()<CR>", { silent = true, desc="Enable diagnostics" })
-- Toggle autofix
vim.api.nvim_set_keymap("n", "<leader>xa", ":lua vim.b.autoformat = false<CR>", { silent = true, desc="Disable autoformat" })
vim.api.nvim_set_keymap("n", "<leader>xA", ":lua vim.b.autoformat = true<CR>", { silent = true, desc="Enable autoformat" })

vim.api.nvim_set_keymap("n" , "<leader>Mc", ':lua require("telescope").extensions.metals.commands()<CR>', { silent = true, desc = 'Commands' })
vim.api.nvim_set_keymap("n" , "<leader>Mi", ':MetalsInfo<CR>', { silent = true, desc = 'Info' })
vim.api.nvim_set_keymap("n" , "<leader>Md", ':MetalsRunDoctor<CR>', { silent = true, desc =  'Doctor' })
vim.api.nvim_set_keymap("n" , "<leader>Mx", ':MetalsDisconnectBuild<CR>', { silent = true, desc =  'DisconnectBuild' })
vim.api.nvim_set_keymap("n" , "<leader>MX", ':MetalsConnectBuild<CR>',  { silent = true, desc = 'ConnectBuild' })
vim.api.nvim_set_keymap("n" , "<leader>MC", ':MetalsCompileCascase<CR>',  { silent = true, desc = 'CompileCascade' })

-- buffer movement
vim.api.nvim_set_keymap("n", "<leader>b<Left>", ":BufferLineMovePrev<CR>", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<leader>b<Right>", ":BufferLineMoveNext<CR>", { silent = true, noremap = true })



------
--- when in command mode, allow using arrows for navigating dropdown options.
---
-- Use <C-j> and <C-k> to navigate the completion list:
vim.api.nvim_set_keymap('c', '<C-j>', 'pumvisible() ? "\\<C-n>" : "\\<C-j>"', { expr = true, noremap = true })
vim.api.nvim_set_keymap('c', '<C-k>', 'pumvisible() ? "\\<C-p>" : "\\<C-k>"', { expr = true, noremap = true })
-- Use arrow keys to navigate the completion list:
vim.api.nvim_set_keymap('c', '<Down>', 'pumvisible() ? "\\<C-n>" : "\\<Down>"', { expr = true, noremap = true })
vim.api.nvim_set_keymap('c', '<Up>', 'pumvisible() ? "\\<C-p>" : "\\<Up>"', { expr = true, noremap = true })
------

-- keymap to Exit terminal mode, and enter normal mode 
vim.keymap.set('t', '<leader><ESC>', '<C-\\><C-n>', { noremap = true, silent = true })


-- Ctrl-a to get to beginning of line in command mode
vim.api.nvim_set_keymap( "c", "<C-a>", "<Home>", { silent = false, noremap = true })

local function open_float_term()
    -- Get the dimensions of the main Neovim window
    local width = vim.api.nvim_get_option_value("columns", {})
    local height = vim.api.nvim_get_option_value("lines", {})

    -- Calculate the width and height of the floating window
    local win_height = math.ceil(height * 0.8 - 4)
    local win_width = math.ceil(width * 0.6)

    -- Calculate the starting position of the floating window
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)

    -- Set up the options for the floating window
    local opts = {
        style = "minimal",
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        border = "rounded"
    }

    -- Create the floating window
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Open a terminal in the new buffer
    vim.fn.termopen(vim.o.shell, {
        on_exit = function()
            vim.api.nvim_win_close(win, true)
        end
    })
    -- Press esc to close the terminal
    vim.keymap.set({'n', 'i', 't', 'v'}, '<Esc>', '<cmd>:q<cr>', {noremap = true, silent = true, buffer=buf})
    -- Enter insert mode
    vim.cmd[[startinsert]]
end
-- CTRL-SHIFT-T to open floating terminal
vim.keymap.set({'n', 'i', 'v'}, '<C-S-t>', function() open_float_term() end, {noremap = true, silent = true})

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
