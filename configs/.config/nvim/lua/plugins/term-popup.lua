return {
  {
    dir = vim.fn.stdpath("config") .. "/plugins/term-popup",
    name = "term-popup",
    lazy = false,
    keys = {
      {
        "<leader><Esc>",
        function() require("term-popup").close() end,
        desc = "Close any open terminal",
        mode = {"n", "v"}
      },
      -- Command-specific terminals with unified toggle behavior
      {
        "<leader>th",
        function() require("term-popup").toggle("htop") end,
        desc = "Toggle htop terminal",
        mode = {"n", "v"}
      },
      {
        "<leader>td",
        function() require("term-popup").toggle("docker stats") end,
        desc = "Toggle docker stats terminal",
        mode = {"n", "v"}
      },
      {
        "<leader>aw",
        function() require("term-popup").toggle("wasabi --no-markdown --auto-accept-edits") end,
        desc = "Toggle Wasabi",
        mode = {"n", "v"}
      },
      {
        "<leader>t<Esc>",
        function() require("term-popup").toggle() end,
        desc = "Toggle default terminal",
        mode = {"n", "v"}
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
