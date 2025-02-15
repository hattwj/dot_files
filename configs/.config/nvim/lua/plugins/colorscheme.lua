vim.g.terminal_color_0 = "#1A1C2A"  -- Even darker for contrast
vim.g.terminal_color_1 = "#FF4D8F"  -- More saturated pink
vim.g.terminal_color_2 = "#50FF50"  -- More saturated green
vim.g.terminal_color_3 = "#FFD700"  -- More saturated yellow (gold)
vim.g.terminal_color_4 = "#4169FF"  -- More saturated blue
vim.g.terminal_color_5 = "#FF69B4"  -- More saturated pink (hot pink)
vim.g.terminal_color_6 = "#00FFFF"  -- More saturated cyan (aqua)
vim.g.terminal_color_7 = "#E6E6FA"  -- More saturated light blue (lavender)
vim.g.terminal_color_8 = "#7B68EE"  -- More saturated medium blue
vim.g.terminal_color_9 = "#FF4D8F"  -- Same as color_1
vim.g.terminal_color_10 = "#50FF50" -- Same as color_2
vim.g.terminal_color_11 = "#FFD700" -- Same as color_3
vim.g.terminal_color_12 = "#4169FF" -- Same as color_4
vim.g.terminal_color_13 = "#FF69B4" -- Same as color_5
vim.g.terminal_color_14 = "#00FFFF" -- Same as color_6
vim.g.terminal_color_15 = "#F0F8FF" -- More saturated very light blue (alice blue)
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
