-- Generic window manager plugin config
return {
  {
    name = "window-manager",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 100,
    config = function()
      local wm = require("window-manager")
      wm.setup({
        keymaps = {
          prefix = "<leader>w"
        }
      })
    end,
  }
}
