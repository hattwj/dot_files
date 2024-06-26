return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  lazy = false,
  config = function()
    local highlight = {
      "CursorColumn",
      "Whitespace",
    }
    require("ibl").setup {
      -- show indentations with differently colored whitespace,
      -- this prevents characters from appearing in copy pasted code.
      indent = { highlight = highlight, char = "" },
      whitespace = {
          highlight = highlight,
          remove_blankline_trail = false,
      },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "help",
          "startify",
          "dashboard",
          "packer",
          "neogitstatus",
          "NvimTree",
          "Trouble",
        }
      }
    }
  end,
}
