return {
  "tokyonight.nvim",
  opts = {
  },
  config = function()
     vim.cmd("highlight WinSeparator guifg=orange")
     require("tokyonight").setup({
       -- other configs
       on_colors = function(colors)
         -- colors.border = "#5f87d7" -- blue
         colors.border = "orange"
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
