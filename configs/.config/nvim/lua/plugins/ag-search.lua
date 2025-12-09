-- Custom :Ag command with file type filtering
-- Usage: :Ag something --ruby
--        :Ag --js potato
--        :Ag error message --python
-- Visual mode: Select text, then :'<,'>Ag --cpp

return {
  {
    dir = vim.fn.stdpath("config") .. "/plugins/ag-search",
    name = "ag-search",
    lazy = false,
    config = function()
      require("ag-search").setup()
    end,
  }
}
