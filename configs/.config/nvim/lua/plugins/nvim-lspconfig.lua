return {
  "neovim/nvim-lspconfig",
  opts = {
    -- TODO: Add barium: https://w.amazon.com/bin/view/Barium/
    --
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

        cmd = { "solargraph" }
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
      metals = {
        keys = {
          {
            "<leader>me",
            function()
              require("telescope").extensions.metals.commands()
            end,
            desc = "Metals commands",
          },
          {
            "<leader>mc",
            function()
              require("metals").compile_cascade()
            end,
            desc = "Metals compile cascade",
          },
        },
        init_options = {
          buildTool = 'brazil-build',
          statusBarProvider = "on",
        },
        settings = {
          metalsBinaryPath = vim.fn.expand("~/.local/share/coursier/bin/metals"),
          autoImportBuild = "off",
          sbtScript = "brazil-build -Dsbt.override.build.repos=false -Dsbt.offline=false -Dbloop=true",
          defaultBspToBuildTool = true,
          -- showImplicitConversionsAndClasses = true,
          superMethodLensesEnabled = true,
          showInferredType = true,
          excludedPackages = {
            "akka.actor.typed.javadsl",
            "com.github.swagger.akka.javadsl",
            "akka.stream.javadsl",
          },
          --fallbackScalaVersion = "2.12.9",
          -- JAVA 8
          serverVersion = "1.3.0",
          showImplicitArguments = true,
        },
      },
    },
  },
}
