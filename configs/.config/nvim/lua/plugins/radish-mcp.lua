return {
  {
    dir = vim.fn.stdpath("config") .. "/plugins/radish-mcp",
    name = "radish-mcp",
    lazy = false,
    config = function()
      require("radish-mcp").setup({
        auto_start = true  -- Start MCP server on VimEnter
      })
    end,
  }
}
