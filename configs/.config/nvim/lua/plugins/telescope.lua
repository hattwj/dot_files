return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  keys = {
      -- Used in keymaps to find files without git
      { "<leader>ff", false },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      pickers = {
        live_grep = {
          file_ignore_patterns = {
            "node_modules/",
            ".git/",
            ".venv/",
            "build/",
            ".bsp/",
            ".metals/",
            ".bloop/",
            "target/",
            ".brazil/"
          },
          additional_args = function(_)
            return { "--hidden" }
          end,
        },
        find_files = {
          file_ignore_patterns = { 
            "node_modules/",
            ".git/",
            ".venv/",
            "build/",
            ".bsp/",
            ".metals/",
            ".bloop/",
            "target/",
            ".brazil/"
          },
          hidden = true,
        },
      },
    })
  end,
}
