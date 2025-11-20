# term-popup.nvim

A multi-position terminal plugin for Neovim with runtime mode switching and persistent terminal sessions.

## Features

- **5 Display Modes**: bottom split, top split, right split, left split, float (popover)
- **Runtime Mode Switching**: Change terminal positions on-the-fly without restarting
- **Persistent Sessions**: Terminal state maintained across open/close cycles
- **Unique Terminals**: Each command gets its own terminal instance
- **Non-Immersive Splits**: Split modes don't trigger terminal title changes
- **Multiple Terminals**: Run different commands simultaneously in different positions

## Quick Start

**Default Usage:**
```
<leader>th    → Toggle htop in current mode (default: bottom split)
<leader>tm    → Cycle modes: bottom → right → float → bottom
:PopupTerminalMode right    → Switch to right split mode
```

## Keybindings

### Terminal Commands
- `<leader>th` - Toggle htop terminal
- `<leader>td` - Toggle docker stats terminal
- `<leader>aw` - Toggle Wasabi terminal
- `<leader>t<Esc>` - Toggle default terminal
- `<leader><Esc>` - Close focused terminal

### Mode Switching
- `<leader>tm` - Cycle through modes
- `<leader>tmb` - Set mode to bottom
- `<leader>tmt` - Set mode to top
- `<leader>tmr` - Set mode to right
- `<leader>tml` - Set mode to left
- `<leader>tmf` - Set mode to float
- `<leader>tca` - Close all terminals

## Vim Command

```vim
:PopupTerminalMode          " Show current mode
:PopupTerminalMode bottom   " Set mode to bottom
:PopupTerminalMode<Tab>     " Tab completion
```

## Configuration

See `lua/plugins/term-popup.lua` for full configuration options.

## License

MIT License
