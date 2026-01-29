-- add more treesitter parsers
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    -- Compile parsers from source (fixes GLIBC_2.33 errors on AL2)
    prefer_git = true,
    ensure_installed = {
      "bash",
      "embedded_template",
      "html",
      "ini",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "ruby",
      "scala",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "yaml",
    },
  },
}
