-- add more treesitter parsers
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
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
