vim.api.nvim_create_user_command("SpellSuggest", function()
  local word = vim.fn.expand("<cword>")
  local suggestions = vim.fn.spellsuggest(word)
  if #suggestions > 0 then
    vim.ui.select(suggestions, {
      prompt = "Select spelling suggestion:",
      format_item = function(item)
        return item
      end,
    }, function(selected)
      if selected then
        vim.cmd("normal! ciw" .. selected)
      end
    end)
  else
    print("No spelling suggestions found.")
  end
end, {})

-- Map 'z=' to the custom spelling suggestion command
vim.api.nvim_set_keymap('n', '\\s', ':SpellSuggest<CR>', { noremap = true, silent = true })
