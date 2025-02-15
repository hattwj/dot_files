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

if vim.g.neovide then
  vim.g.gui_font = "DroidSansM Nerd Font"
  vim.g.gui_fontsize = 10
  vim.api.nvim_set_option_value("clipboard", "unnamedplus", {})
  vim.g.neovide_transparency = 0.9
  vim.g.neovide_normal_opacity = 0.9
  vim.g.neovide_scale_factor = 0.8
  vim.g.neovide_floating_blur_amount_x = 3.0
  vim.g.neovide_floating_blur_amount_y = 3.0
  vim.g.neovide_window_blurred = true

  -- Summons a cat that causes the mouse to disappear while typing
  vim.g.neovide_hide_mouse_when_typing = true

  -- ctrl +- to alter font size
  local function adjust_font_size(amount)
      vim.g.gui_fontsize = vim.g.gui_fontsize + amount
      vim.o.guifont = vim.g.gui_font .. ":h" .. vim.g.gui_fontsize
      print("Font Size: ".. vim.g.gui_fontsize)
  end

  vim.keymap.set('n', '<C-kPlus>', function() adjust_font_size(1) end, { noremap = true, silent = true })
  vim.keymap.set('n', '<C-kMinus>', function() adjust_font_size(-1) end, { noremap = true, silent = true })

  vim.keymap.set('n', '<C-+>', function() adjust_font_size(1) end, { noremap = true, silent = true })
  vim.keymap.set('n', '<C-->', function() adjust_font_size(-1) end, { noremap = true, silent = true })

  -- In neovide we are able to use the ALT key for keymaps, so we use it here for window navigation.
  -- This is similar to the keymap used in terminator to switch between terminals
  vim.keymap.set({'n', 'i', 't', 'v'}, '<A-Up>', '<C-\\><C-n><C-w><Up><CR>', { noremap = true, silent = true })
  vim.keymap.set({'n', 'i', 't', 'v'}, '<A-Down>', '<C-\\><C-n><C-w><Down><CR>', { noremap = true, silent = true })
  vim.keymap.set({'n', 'i', 't', 'v'}, '<A-Left>', '<C-\\><C-n><C-w><Left><CR>', { noremap = true, silent = true })
  vim.keymap.set({'n', 'i', 't', 'v'}, '<A-Right>', '<C-\\><C-n><C-w><Right><CR>', { noremap = true, silent = true })

  -- Ctrl-V to paste into command from system clipboard
  -- Silent false appears to be important, otherwise you have to press an arrow key
  -- to get it to refresh.
  vim.api.nvim_set_keymap( "c", "<C-v>", "<C-r>+<Right>", { silent = false, noremap = true })

  -- ctrl +- to alter font size
  local function zoom_with_resize()
    Snacks.zen.zoom()
    if vim.g.neovide_scale_factor > 1 then
        vim.g.neovide_scale_factor = 0.8
    else
        vim.g.neovide_scale_factor = 1.25
    end
  end

  -- Zoom with resize in scaling
  vim.keymap.set('n', '<C-S-z>', function() zoom_with_resize() end, { noremap = true, silent = true })
  vim.keymap.set('i', '<C-S-z>', function() zoom_with_resize() end, { noremap = true, silent = true })
  vim.keymap.set('v', '<C-S-z>', function() zoom_with_resize() end, { noremap = true, silent = true })
  vim.keymap.set('t', '<C-S-z>', function()
    vim.cmd[[stopinsert]]
    zoom_with_resize()
    vim.cmd[[startinsert]]
    end, { noremap = true, silent = true })

  -- Zoom with no resize in scaling
  vim.api.nvim_set_keymap('n', '<C-S-x>', '<cmd>lua Snacks.zen.zoom()<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('i', '<C-S-x>', '<cmd>lua Snacks.zen.zoom()<CR>', { noremap = true, silent = true })
  vim.api.nvim_set_keymap('v', '<C-S-x>', '<cmd>lua Snacks.zen.zoom()<CR>', { noremap = true, silent = true })
  vim.keymap.set('t', '<C-S-x>', function() Snacks.zen.zoom() end, { noremap = true, silent = true })

  -- Mouse control left click to open url under cursor
  vim.keymap.set({'n', 'i', 't', 'v'}, '<C-LeftMouse>', function() vim.cmd.normal[[gx]] end, { noremap = true, silent = true })
end
