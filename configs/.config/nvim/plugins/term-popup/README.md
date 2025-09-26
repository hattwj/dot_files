# term-popup.nvim

A persistent floating terminal popup plugin for Neovim with LazyVim integration.

## Features

- **Persistent terminal sessions** - Terminal state is maintained across open/close cycles
- **Floating window** - Clean, centered popup with configurable size and border
- **Universal keybinding** - Same key combination to open and close from any mode
- **LazyVim integration** - Proper plugin structure and configuration

## Installation

This plugin is already installed in your LazyVim setup via the local plugin system.

## Usage

### Default Keybinding
- `<Esc><Esc>` - Toggle the persistent terminal from normal, insert, or visual mode
- `<Esc><Esc>` - Close the terminal from within terminal mode

### API Functions

```lua
local term_popup = require("term-popup")

-- Toggle terminal visibility
term_popup.toggle()

-- Open terminal (if not already open)
term_popup.open()

-- Close terminal (if open)
term_popup.close()

-- Check if terminal is currently open
if term_popup.is_open() then
  print("Terminal is open!")
end

-- Get the terminal buffer ID
local buf_id = term_popup.get_buf()
```

## Configuration

The plugin can be configured in your LazyVim plugin spec:

```lua
return {
  {
    dir = vim.fn.stdpath("config") .. "/plugins/term-popup",
    name = "term-popup",
    config = function()
      require("term-popup").setup({
        size = {
          width = 0.9,   -- 90% of screen width
          height = 0.7,  -- 70% of screen height
        },
        border = "single",  -- "single", "double", "rounded", "solid", "shadow"
        shell = "/bin/bash",  -- Custom shell (defaults to vim.o.shell)
        keymaps = {
          toggle = "<C-t>",  -- Custom toggle key
        }
      })
    end
  }
}
```

### Default Configuration

```lua
{
  size = {
    width = 0.8,   -- 80% of screen width
    height = 0.8,  -- 80% of screen height
  },
  border = "rounded",
  shell = nil,  -- Uses vim.o.shell
  keymaps = {
    toggle = "<Esc><Esc>",
  }
}
```

## How It Works

1. **First toggle**: Creates a new terminal buffer and floating window
2. **Subsequent closes**: Only closes the window, keeping the terminal process alive
3. **Subsequent opens**: Reopens the same terminal session with all history intact
4. **Process persistence**: Running commands, directory changes, and shell history are all maintained

## License

MIT License
