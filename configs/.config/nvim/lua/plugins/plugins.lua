return {
  { "tpope/vim-fugitive" },
  { "airblade/vim-gitgutter" },
  { "dense-analysis/ale" },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "moon",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  -- { "kien/rainbow_parentheses.vim" },
  -- { "mileszs/ack.vim" },
}
