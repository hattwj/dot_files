return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    terminal_colors = false, -- Don't configure the colors used when opening a `:terminal` in Neovim
    styles = {
      sidebars = "transparent",
      floats = "transparent",
    },
    transparent = true,
    on_colors = function(colors)
      -- colors.border = "#5f87d7" -- blue
      colors.border = "orange"
    end,
  },
}
