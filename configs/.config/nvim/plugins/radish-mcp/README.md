# radish-mcp.nvim

A Model Context Protocol (MCP) server plugin for Neovim that enables AI assistants like Wasabi to interact with your editor through Unix domain sockets.

**Name**: "Radish" - because it's red and grows in gardens (where code is cultivated) 🌱

## Features

- **MCP Protocol Implementation**: Native Lua implementation of MCP JSON-RPC protocol
- **TTY-Based Socket Naming**: Each terminal session gets its own socket
- **Multiple Instance Support**: Run multiple Neovim instances without conflicts
- **Auto-Start**: Server starts automatically when Neovim launches
- **Basic Tools**: Buffer reading, status queries, command execution
- **Preview Support**: (Coming soon) Live file change previews

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

## License

MIT License
