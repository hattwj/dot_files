return {
  {
    dir = vim.fn.stdpath("config") .. "/plugins/term-popup",
    name = "term-popup",
    lazy = false,
    keys = {
      {
        "<leader><Esc>",
        function() require("term-popup").toggle() end,
        desc = "Toggle persistent terminal",
        mode = {"n", "i", "v"}
      },
    },
    config = function()
      require("term-popup").setup({
        size = {
          width = 0.8,  -- 80% of screen width
          height = 0.8, -- 80% of screen height
        },
        border = "rounded",
      })
    end,
  }
}
