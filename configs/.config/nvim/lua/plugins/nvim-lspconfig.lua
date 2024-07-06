return {
  "neovim/nvim-lspconfig",
  opts = {
    -- Automatically format on save, this doesn't seem to work
    autoformat = false,
    servers = {
      bashls = {
        filetypes = { "sh", "zsh" },
      },
      solargraph = {
        -- https://github.com/castwide/solargraph/issues/483#issuecomment-926516460
        -- these two options disable rubocop
        autoformat = false,
        formatting = false,

        cmd = { "solargraph"}
      },
      -- This looks like it disables the lsp,
      -- but as far as I can tell it just prevents
      -- installing it, otherwise still used. 
      -- Allowing manual installation
      ruff_lsp = false,
      -- ruff_lsp = {
      --   cmd = { "ruff-lsp" }
      -- },
      -- ruby_lsp = {
      --   cmd = { "rvm use 3.1.0 && ruby-lsp" },
      --   init_options = {
      --     formatter = "auto",
      --   },
      -- },
      -- rubocop = {
      --   -- See: https://docs.rubocop.org/rubocop/usage/lsp.html
      --   cmd = { "bundle", "exec", "rubocop", "--lsp" },
      --   root_dir = lspconfig.util.root_pattern("Gemfile", ".git", "."),
      -- },
      metals = true,
      -- metals = {
      --   keys = {
      --     {
      --       "<leader>me",
      --       function()
      --         require("telescope").extensions.metals.commands()
      --       end,
      --       desc = "Metals commands",
      --     },
      --     {
      --       "<leader>mc",
      --       function()
      --         require("metals").compile_cascade()
      --       end,
      --       desc = "Metals compile cascade",
      --     },
      --   },
      --   init_options = {
      --     statusBarProvider = "off",
      --   },
      --   settings = {
      --     showImplicitArguments = true,
      --     excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
      --   },
      -- },
    },
  },
}
