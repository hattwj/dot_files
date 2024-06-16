return {
  -- Find existing keymaps by looking in ~/.config/nvim 
  -- Grep for patterns matching the description found in the 
  -- which-key menu
 { "folke/which-key.nvim",
    keys = {
      -- Now used to close current buffer
      {'<leader>q', false }    
    }
  },
  { 
    "ibhagwan/fzf-lua",
    keys = {
      -- Now used to find git commits
      {'<leader>fc', false}
    }
  }
  -- { "folke/noice.nvim", enabled = false },
}
