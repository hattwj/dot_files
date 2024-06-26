-- Scope buffers to tabs, don't show all buffers in every tab
return {
  "tiagovla/scope.nvim",
  config = function()
    -- Autoload tab filter that only shows buffers for the current tab in the bufferline
    require("scope").setup({})
  end,
}

