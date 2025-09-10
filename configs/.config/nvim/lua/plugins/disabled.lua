return {
  -- Find existing keymaps by looking in ~/.config/nvim
  -- Grep for patterns matching the description found in the
  -- which-key menu
 { "folke/which-key.nvim",
    keys = {
      -- Now used to close current buffer
      {'<leader>q', false },
      -- Now used to telescope show git status
      {'<leader>fg', false}
    }
  },
  {
    "ibhagwan/fzf-lua",
    keys = {
      -- Now used to find git commits
      {'<leader>fc', false},
      {'<leader>gd', false}
    }
  },
  -- { "folke/noice.nvim", enabled = false },
}
