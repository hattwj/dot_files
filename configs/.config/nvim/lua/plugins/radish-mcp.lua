return {
  {
    dir = vim.fn.stdpath("config") .. "/plugins/radish-mcp",
    name = "radish-mcp",
    lazy = false,
    config = function()
      require("radish-mcp").setup({
        auto_start = true,  -- Start MCP server on VimEnter
        monitor = {
          enabled = true,
          poll_interval_ms = 500,
          auto_show_ghost = true,
        }
      })

      -- Register patterns for Wasabi file operations
      vim.defer_fn(function()
        local pattern_registry = require('radish-mcp.pattern-registry')

        -- Pattern 1: Successful file writes
        pattern_registry.register({
          name = "ai_agent_file_writes",
          pattern = "Auto%-accepting changes to",  -- Detect the line first
          priority = 100,
          description = "Detects AI agent file write actions",
          handler = function(matches, context)
            -- Get joined line to handle terminal wrapping
            local joined_line = context.get_joined_line(2)

            -- Extract filepath from joined line
            local filepath = joined_line:match("Auto%-accepting changes to ([^:]+)")
            if not filepath then
              return false
            end

            -- Prepend working directory if relative path
            if not filepath:match("^/") then
              filepath = vim.fn.getcwd() .. "/" .. filepath
            end

            -- Show in ghost window
            context.show_in_ghost(filepath)

            -- Auto-trigger ghost flash watcher
            vim.schedule(function()
              local ok, orchestrator = pcall(require, 'radish-mcp.ghost-flash-orchestrator')
              if ok and orchestrator and orchestrator.config.enabled then
                print(string.format("🎯 [Pattern] Auto-starting ghost watch for: %s", vim.fn.fnamemodify(filepath, ":t")))
                orchestrator.watch_and_flash(filepath)
              end
            end)

            return false
          end,
        })

        -- Pattern 2: No-change updates
        pattern_registry.register({
          name = "ai_agent_no_changes",
          pattern = "no changes to",
          priority = 100,
          description = "Detects AI agent no-change messages",
          handler = function(matches, context)
            local joined_line = context.get_joined_line(2)
            local filepath = joined_line:match("no changes to ([^,]+)")
            if not filepath then
              return false
            end
            if not filepath:match("^/") then
              filepath = vim.fn.getcwd() .. "/" .. filepath
            end
            context.show_in_ghost(filepath)
            return false
          end,
        })

        -- -- Pattern 3: File reads
        -- pattern_registry.register({
        --   name = "ai_agent_file_reads",
        --   pattern = "Reading file",
        --   priority = 100,
        --   description = "Detects AI agent file read actions",
        --   handler = function(matches, context)
        --     local joined_line = context.get_joined_line(4)
        --     local filepath = joined_line:match("Reading file ([^%s]+)")
        --     if not filepath then
        --       return false
        --     end
        --     if not filepath:match("^/") then
        --       filepath = vim.fn.getcwd() .. "/" .. filepath
        --     end
        --     context.show_in_ghost(filepath)
        --     return false
        --   end,
        -- })
      end, 200)
    end,
  }
}
