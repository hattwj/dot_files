return {
  {
    dir = vim.fn.stdpath("config") .. "/plugins/term-popup",
    name = "term-popup",
    lazy = false,
    keys = {
      {
        "<leader><Esc>",
        function() require("term-popup").close() end,
        desc = "Close focused terminal",
        mode = {"n", "v"}
      },
      -- Command-specific terminals with unified toggle behavior
      {
        "<leader>th",
        function() require("term-popup").toggle("htop", "right") end,
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
        "<leader>t<Esc>",
        function() require("term-popup").toggle(nil, "float") end,
        desc = "Toggle default terminal",
        mode = {"n", "v"}
      },

      -- Mode switching keybindings
      {
        "<leader>tm",
        function() require("term-popup").toggle_mode() end,
        desc = "Cycle terminal mode",
        mode = {"n", "v"}
      },
      {
        "<leader>tmb",
        function() require("term-popup").set_mode("bottom") end,
        desc = "Terminal mode: bottom",
        mode = {"n", "v"}
      },
      {
        "<leader>tmt",
        function() require("term-popup").set_mode("top") end,
        desc = "Terminal mode: top",
        mode = {"n", "v"}
      },
      {
        "<leader>tmr",
        function() require("term-popup").set_mode("right") end,
        desc = "Terminal mode: right",
        mode = {"n", "v"}
      },
      {
        "<leader>tml",
        function() require("term-popup").set_mode("left") end,
        desc = "Terminal mode: left",
        mode = {"n", "v"}
      },
      {
        "<leader>tmf",
        function() require("term-popup").set_mode("float") end,
        desc = "Terminal mode: float",
        mode = {"n", "v"}
      },

      -- Close all terminals
      {
        "<leader>tca",
        function() require("term-popup").close_all() end,
        desc = "Close all terminals",
        mode = {"n", "v"}
      },
    },
    config = function()
      require("term-popup").setup({
        mode = "bottom",  -- Default to split mode for non-immersion-breaking behavior
        split_height = 15,
        split_width = 80,
        size = {
          width = 0.8,
          height = 0.8,
        },
        border = "rounded",
        mode_cycle = {"bottom", "right", "float"},  -- Customize your mode cycle
      })
    end,
  }
}
