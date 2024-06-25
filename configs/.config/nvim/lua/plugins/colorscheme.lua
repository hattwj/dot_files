return {
  "tokyonight.nvim",
  opts = {
  },
  config = function()
     require("tokyonight").setup({
       -- other configs
       on_colors = function(colors)
         colors.border = "#5f87d7"
       end,
       transparent = true,
       colorscheme = 'tokyonight-night',
       styles = {
         sidebars = "transparent",
         floats = "transparent",
       },
     })
  end,
}
