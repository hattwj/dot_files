return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Automatically format on save
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
      },
    },
  },
}
