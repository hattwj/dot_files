
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
    views = {
      mini = { timeout = 8500, },
    },
    cmdline = cmd_config,
    -- routes = {
    --   { -- When a message is more than 40 characters wide, show it as a custom message 
    --     -- with custom rules.
    --     -- view = "virtualtext",
    --     view = "mini",
    --     filter = { event = "msg_show", min_width = 40 },
    --   },
    -- },
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
