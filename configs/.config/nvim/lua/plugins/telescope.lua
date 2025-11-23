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
    local actions = require("telescope.actions")
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
            "tmp/",
            "bower_components/",
            ".brazil/",
            "__snapshots__/"
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
            "tmp/",
            "bower_components/",
            "target/",
            ".brazil/",
            "__snapshots__/"
          },
          hidden = true,
        },
      },
      defaults = {
        mappings = {
          i = {
            -- Open all selected files (or current file if none selected) on Enter
            ["<CR>"] = function(prompt_bufnr)
              local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
              local multi = picker:get_multi_selection()
              if #multi > 0 then
                actions.close(prompt_bufnr)
                for _, entry in ipairs(multi) do
                  vim.cmd(string.format("edit %s", entry.path or entry.filename))
                end
              else
                actions.select_default(prompt_bufnr)
              end
            end,
          },
          n = {
            -- Same mapping for normal mode
            ["<CR>"] = function(prompt_bufnr)
              local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
              local multi = picker:get_multi_selection()
              if #multi > 0 then
                actions.close(prompt_bufnr)
                for _, entry in ipairs(multi) do
                  vim.cmd(string.format("edit %s", entry.path or entry.filename))
                end
              else
                actions.select_default(prompt_bufnr)
              end
            end,
          },
        },
      },
    })
  end,
}
