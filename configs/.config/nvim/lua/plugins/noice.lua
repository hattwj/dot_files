
local cmd_config = {
  view = "cmdline"
}

if vim.g.neovide then
  cmd_config = {}
end

return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    cmdline = cmd_config,
    routes = {
      { -- Disable mini notifications (lower right corner)
        filter = {
          event = "msg_show",
          any = {
            { find = "written" },
            { find = "lines" },
            { find = "more lines" },
            { find = "fewer lines" },
          },
        },
        opts = { skip = true },
      },
      { -- Route other messages to notify instead of mini
        view = "notify",
        filter = { event = "msg_show" },
      },
    },
  },
  config = function(_, opts)
    -- HACK: noice shows messages from before it was enabled,
    -- but this is not ideal when Lazy is installing plugins,
    -- so clear the messages in this case.
    -- if vim.o.filetype == "lazy" then
    --   vim.cmd([[messages clear]])
    -- end
    require("noice").setup(opts)
  end,
}
