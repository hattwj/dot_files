# Ghost Mode - Quick Reference

Auto-display files mentioned in terminal output using pattern matching.

## Quick Start

```vim
" In terminal buffer
:GhostStart

" Watch terminal output get scanned
" Files automatically appear in split window

" When done
:GhostStop
:GhostClose
```

## Commands

- `:GhostStart [buf]` - Start monitoring (current buffer or specified)
- `:GhostStop` - Stop monitoring
- `:GhostToggle` - Toggle on/off
- `:GhostStatus` - Show status
- `:GhostClose` - Close window
- `:GhostPatterns` - List patterns

## Example Pattern

Detect Wasabi file edits:

```lua
-- Add to your config
local pattern_registry = require('radish-mcp.pattern-registry')

pattern_registry.register({
  name = "wasabi_files",
  pattern = "File: (/.+%.lua)",  -- Matches "File: /path/file.lua"
  priority = 100,
  description = "Detects files in Wasabi output",
  handler = function(matches, context)
    local filepath = matches[1]
    context.show_in_ghost(filepath)
    return false  -- Continue to other patterns
  end,
})
```

## How It Works

```
Terminal Output → Monitor polls every 500ms
       ↓
Pattern Registry matches lines
       ↓
Handler extracts filepath
       ↓
Ghost Window displays file (single reusable split)
```

## Configuration

```lua
require("radish-mcp").setup({
  monitor = {
    enabled = true,
    poll_interval_ms = 500,
    auto_show_ghost = true,
    batch_size = 50,
  }
})
```

## Pattern Tips

- Use Lua patterns: `%.` for `.`, `+` for one-or-more
- Capture with `()`: `"File: (/.+)"`
- Priority: lower number = higher priority (10 before 100)
- Return `true` from handler to stop processing

## Testing

```vim
:luafile ~/.config/nvim/plugins/radish-mcp/test-integration.lua
```

See README.md for full documentation.
