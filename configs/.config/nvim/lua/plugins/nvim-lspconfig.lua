local util = require 'lspconfig.util'

return {
  "neovim/nvim-lspconfig",
  opts = {

    -- TODO: Add barium: https://w.amazon.com/bin/view/Barium/
    --
    -- Automatically format on save, this doesn't seem to work
    autoformat = false,

    servers = {
      -- Harper Language Server - Comprehensive Configuration
      harper_ls = {
        -- File types to enable harper-ls for
        filetypes = {
          "markdown", "text", "txt", "gitcommit",
          "latex", "tex", "rst", "asciidoc", "org"
        },

        -- Server settings passed to harper-ls
        settings = {
          ["harper-ls"] = {
            -- Linting and diagnostics settings
            linters = {
              spell_check = true,
              long_sentences = true,
              repeated_words = true,
              spaces = true,
              sentence_capitalization = true,
              unclosed_quotes = true,
              wrong_quotes = true,
              linking_verbs = true,
              avoid_curses = false,
            },

            -- Code actions settings
            codeActions = {
              forceStable = true,
            },

            -- Diagnostics configuration
            diagnostics = {
              -- Enable/disable specific diagnostic types
              enable = true,
              -- Severity levels: "error", "warning", "information", "hint"
              severity = "information",
              -- Update frequency
              update_on_insert = false,
              update_on_save = true,
            },

            -- Dictionary and language settings
            dictionary = {
              -- Path to custom dictionary file
              path = vim.fn.expand("~/.config/harper-ls/dictionary.txt"),
              -- Language code (en, es, fr, etc.)
              language = "en",
            },

            -- Performance settings
            performance = {
              max_file_size = 1000000,  -- 1MB limit
            },
          },
        },
      },
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
      --
      -- Ruby 
      --

      sorbet = {enabled = false},

      typeprof = {enabled = true },

      ruby_lsp = {
        capabilities = {
          offsetEncoding = { "utf-16" },
        },
        init_options = {
          formatter = "auto",
        },
      },
      rubocop = {
        root_dir = util.root_pattern("Gemfile", ".git", "."),
      },
      -- Scala 
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
