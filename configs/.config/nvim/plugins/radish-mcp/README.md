# radish-mcp.nvim

A Model Context Protocol (MCP) server plugin for Neovim that enables AI assistants like Wasabi to interact with your editor through Unix domain sockets.

**Name**: "Radish" - because it's red and grows in gardens (where code is cultivated) 🌱

## Features

- **MCP Protocol Implementation**: Native Lua implementation of MCP JSON-RPC protocol
- **TTY-Based Socket Naming**: Each terminal session gets its own socket
- **Multiple Instance Support**: Run multiple Neovim instances without conflicts
- **Auto-Start**: Server starts automatically when Neovim launches
- **Basic Tools**: Buffer reading, status queries, command execution
- **Preview Support**: Live file change previews
- **Ghost Mode**: Auto-display files mentioned in terminal output

## Architecture

```
┌──────────┐  stdio  ┌─────────────┐  unix   ┌──────────────┐  lua   ┌────────┐
│ Wasabi   │◄───────→│  Bridge     │ socket  │ Radish MCP   │  API   │ Neovim │
│          │         │  (Python)   │◄───────→│ Server       │◄──────→│        │
└──────────┘         └─────────────┘         └──────────────┘        └────────┘
```

## Socket Naming

The plugin creates unique sockets per terminal session:

- **TTY-based**: `/tmp/radish-nvim-pts-5.sock` (for `/dev/pts/5`)
- **PID fallback**: `/tmp/radish-nvim-pid-12345.sock` (non-TTY environments)

This allows multiple Neovim instances to run simultaneously without conflicts.

## Available Tools

### vim_buffer
Get buffer contents with line numbers.

**Arguments:**
- `filename` (optional): Specific buffer to read, defaults to current

**Returns:** Buffer contents with line numbers

### vim_status
Get comprehensive Neovim status.

**Returns:**
- `cursorPosition`: Current cursor location [line, col]
- `mode`: Current vim mode
- `fileName`: Current buffer filename
- `cwd`: Current working directory
- `buffers`: Number of open buffers

### vim_command
Execute vim command.

**Arguments:**
- `command` (required): Vim command to execute

**Returns:** Success or error message

### vim_preview_change
Preview changes to a file before applying. (TODO)

**Arguments:**
- `file` (required): File path to preview
- `changes` (required): Content changes to preview
- `mode` (optional): Display mode - "inline", "split", or "float"

## Configuration

See `lua/plugins/radish-mcp.lua` for configuration options.

Default setup:
```lua
require("radish-mcp").setup({
  auto_start = true  -- Start server on VimEnter
})
```

## Integration

### With Wasabi

Add to your MCP servers config (`~/.ees-interactive-repl/mcp-servers.json`):

```json
{
  "mcpServers": {
    "neovim-radish": {
      "command": "/home/ANT.AMAZON.COM/hatt/bin/nvim-mcp-bridge",
      "args": []
    }
  }
}
```

Then run Wasabi from the same terminal as Neovim:
```bash
wasabi --mcp-servers ~/.ees-interactive-repl/mcp-servers.json
```

## Usage

The plugin starts automatically. You can verify it's running:

```vim
:lua print(require("radish-mcp").socket_path)
```

Check socket exists:
```bash
ls /tmp/radish-nvim-*.sock
```

## Development

### Adding New Tools

1. Add tool definition in `handlers["tools/list"]`
2. Implement handler in `tool_handlers`
3. Restart Neovim to test

### Testing

Use the bridge test script:
```bash
~/dddot_files/bin/test-mcp-bridge
```

Or manually test with echo:
```bash
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | ~/dddot_files/bin/nvim-mcp-bridge
```

## Future Features

- [ ] Live file change previews with visual diffs
- [ ] Streaming updates for real-time changes
- [ ] Multi-file change queues
- [ ] Accept/reject keybindings for previews
- [ ] Virtual text overlays
- [ ] Split/float preview modes

## Ghost Mode

Ghost Mode automatically monitors terminal output and displays referenced files in a persistent split window.

### Quick Start

1. **Open a terminal buffer** (`:term` or existing Wasabi terminal)
2. **Start monitoring:** `:GhostStart`
3. **Terminal output gets scanned** for file paths
4. **Files automatically appear** in ghost window (right split)
5. **Stop when done:** `:GhostStop` and `:GhostClose`

### User Commands

| Command | Description |
|---------|-------------|
| `:GhostStart [buf_id]` | Start monitoring terminal |
| `:GhostStop` | Stop monitoring |
| `:GhostToggle` | Toggle monitoring on/off |
| `:GhostStatus` | Show monitoring status |
| `:GhostClose` | Close ghost window |
| `:GhostPatterns` | List registered patterns |

### Configuration

```lua
require("radish-mcp").setup({
  auto_start = true,
  monitor = {
    enabled = true,           -- Enable ghost mode
    poll_interval_ms = 500,   -- Check every 500ms
    auto_show_ghost = true,   -- Auto-open ghost window
    batch_size = 50,          -- Lines to process at once
  }
})
```

### Custom Patterns

Register patterns to detect file paths in terminal output:

```lua
local pattern_registry = require('radish-mcp.pattern-registry')

pattern_registry.register({
  name = "file_detector",
  pattern = "Updated: (/.+%.lua)",  -- Lua pattern
  priority = 100,  -- Lower = higher priority
  description = "Detects file updates",
  handler = function(matches, context)
    local filepath = matches[1]
    context.show_in_ghost(filepath)  -- Show in ghost window
    return false  -- Continue processing
  end,
})
```

### Architecture

```
Terminal Output
      ↓
Terminal Monitor (polls every 500ms)
      ↓
Pattern Registry (matches patterns)
      ↓
Pattern Handlers (show files)
      ↓
Ghost Window (single reusable split)
```

### Components

- **Pattern Registry** (`pattern-registry.lua`): Extensible pattern matching
- **Terminal Monitor** (`terminal-monitor.lua`): Polls terminal for new lines
- **Ghost Window** (`ghost-window.lua`): Single reusable split window
- **State** (`state.lua`): Tracks buffer, position, history

### Testing

```vim
" Run full integration test
:luafile ~/.config/nvim/plugins/radish-mcp/test-integration.lua

" Test individual components
:luafile ~/.config/nvim/plugins/radish-mcp/test-pattern-registry.lua
:luafile ~/.config/nvim/plugins/radish-mcp/test-ghost-window.lua
```

### Tips

- Only monitor one terminal at a time
- Default 500ms polling balances responsiveness vs CPU
- Lower pattern priority numbers run first (1 before 100)
- Handler returns `true` to stop processing other patterns
- Ghost file history limited to 100 entries

See test files for more examples.

## License

MIT License
