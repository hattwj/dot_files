-- Custom :Ax command with file type filtering
-- Usage: :Ax something --ruby
--        :Ax --js potato
--        :Ax error message --python

return {
  {
    name = "ax-search",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 100,
    config = function()
      -- File type extension mappings
      local file_types = {
        ruby = { "*.rb", "*.rake", "Rakefile", "Gemfile", "*.gemspec" },
        rb = { "*.rb", "*.rake", "Rakefile", "Gemfile", "*.gemspec" },
        python = { "*.py", "*.pyw" },
        py = { "*.py", "*.pyw" },
        javascript = { "*.js", "*.jsx", "*.mjs", "*.cjs" },
        js = { "*.js", "*.jsx", "*.mjs", "*.cjs" },
        typescript = { "*.ts", "*.tsx" },
        ts = { "*.ts", "*.tsx" },
        lua = { "*.lua" },
        rust = { "*.rs" },
        rs = { "*.rs" },
        java = { "*.java" },
        kotlin = { "*.kt", "*.kts" },
        kt = { "*.kt", "*.kts" },
        scala = { "*.scala" },
        go = { "*.go" },
        c = { "*.c", "*.h" },
        cpp = { "*.cpp", "*.cc", "*.cxx", "*.hpp", "*.hxx" },
        shell = { "*.sh", "*.bash", "*.zsh" },
        sh = { "*.sh", "*.bash", "*.zsh" },
        yaml = { "*.yml", "*.yaml" },
        yml = { "*.yml", "*.yaml" },
        json = { "*.json" },
        markdown = { "*.md", "*.markdown" },
        md = { "*.md", "*.markdown" },
      }

      -- Parse search query and file type flags
      local function parse_ag_args(args)
        local query_parts = {}
        local file_type = nil

        -- Split args into words
        for word in args:gmatch("%S+") do
          -- Check if it's a file type flag (--type)
          local flag_type = word:match("^%-%-(.+)$")
          if flag_type and file_types[flag_type] then
            file_type = flag_type
          else
            table.insert(query_parts, word)
          end
        end

        local query = table.concat(query_parts, " ")
        return query, file_type
      end

      -- Create :Ax command
      vim.api.nvim_create_user_command("Ax", function(opts)
        local query, file_type = parse_ag_args(opts.args)

        if query == "" then
          vim.notify("No search query provided", vim.log.levels.WARN)
          return
        end

        local telescope_opts = {
          default_text = query,
        }

        -- Add file type filtering if specified
        if file_type then
          local globs = file_types[file_type]
          telescope_opts.prompt_title = "Grep (" .. file_type .. " files)"
          telescope_opts.vimgrep_arguments = vim.list_extend(
            { "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
            vim.tbl_map(function(glob) return "--glob=" .. glob end, globs)
          )
        end

        require("telescope.builtin").live_grep(telescope_opts)
      end, {
        nargs = "+",
        desc = "Search with optional file type (e.g., :Ax query --ruby)",
      })
    end,
  }
}
