# term-popup.nvim

A multi-position terminal plugin for Neovim with runtime mode switching.

## Features

- **5 Display Modes**: bottom, top, right, left, float (popover)
- **Runtime Mode Switching**: Change default position anytime
- **Per-Keybinding Mode**: Each terminal can have its own position
- **Non-Immersive Splits**: Split modes don't change terminal title
- **Multiple Terminals**: Run different commands simultaneously

## Quick Start

```
<leader>th    → Toggle htop (configured for right split)
<leader>aw    → Toggle wasabi (configured for float)
<leader>td    → Toggle docker stats (uses default mode)
<leader>tm    → Cycle default mode: bottom → right → float
```

## Keybindings

### Terminals (Pre-configured Positions)
- `<leader>th` - htop in **right** split
- `<leader>aw` - wasabi in **float** (popover)
- `<leader>td` - docker stats (uses **default mode**)
- `<leader>t<Esc>` - default terminal (uses **default mode**)
- `<leader><Esc>` - close focused terminal

### Mode Switching (Changes Default)
- `<leader>tm` - cycle: bottom → right → float
- `<leader>tmb/t/r/l/f` - set to bottom/top/right/left/float
- `<leader>tca` - close all terminals

## Vim Command

```vim
:PopupTerminalMode          " Show current default mode
:PopupTerminalMode right    " Set default to right
:PopupTerminalMode<Tab>     " Tab complete modes
```

## Configuration

### Customize Modes Per Terminal

In `lua/plugins/term-popup.lua`, pass mode as second parameter:

```lua
{
  "<leader>th",
  function() require("term-popup").toggle("htop", "right") end,  -- Always right
  desc = "Toggle htop",
},
{
  "<leader>aw",
  function() require("term-popup").toggle("wasabi", "float") end,  -- Always float
  desc = "Toggle wasabi",
},
{
  "<leader>td",
  function() require("term-popup").toggle("docker stats") end,  -- Uses default mode
  desc = "Toggle docker stats",
},
```

### Global Settings

```lua
require("term-popup").setup({
  mode = "bottom",              -- Default mode for terminals without explicit mode
  split_height = 15,            -- Height for horizontal splits (lines)
  split_width = 80,             -- Width for vertical splits (cols or 0.0-1.0 for %)
  mode_cycle = {"bottom", "right", "float"},  -- Order for <leader>tm
})
```

## Usage Examples

### Multiple Terminals in Different Positions

```vim
<leader>th      " htop opens in right split
<leader>td      " docker stats opens in bottom split
<leader>aw      " wasabi opens as float (overlays the splits)

" All three visible! htop on right, docker on bottom, wasabi floating
```

### Change Default Mode

```vim
:PopupTerminalMode right    " Change default to right
<leader>td                  " docker stats now opens in right (not bottom)
<leader>th                  " htop still opens in right (explicit in keybinding)
```

### Cycle Through Modes

```vim
<leader>tm      " bottom → right
<leader>tm      " right → float
<leader>tm      " float → bottom
```

## API

```lua
local term = require("term-popup")

-- Toggle terminal with optional mode
term.toggle(command, mode)        -- mode is optional, uses default if nil

-- Examples
term.toggle("htop", "right")      -- htop in right split
term.toggle("docker stats")       -- uses default mode

-- Mode management
term.set_mode("right")            -- Set default mode
term.get_mode()                   -- Get current default mode
term.toggle_mode()                -- Cycle through mode_cycle

-- Close operations
term.close()                      -- Close focused terminal
term.close_all()                  -- Close all terminals
```

## Design Philosophy

**Simple > Complex:**
- Mode specified directly in keybinding (explicit)
- No runtime per-command configuration needed
- Change default mode for terminals without explicit mode
- What you see in config is what you get

**Priority:**
1. Mode in keybinding: `toggle("htop", "right")` → always right
2. Default mode: `toggle("docker")` → uses current default

## Visual Layouts

**Mixed positions:**
```
┌──────────────────────┬──────────┐
│                      │          │
│  Code editing        │  htop    │
│                      │  [right] │
├──────────────────────┴──────────┤
│ docker stats [bottom]           │
└─────────────────────────────────┘
```

**Float over splits:**
```
┌─────────────────────────────────┐
│     ┌───────────────────┐       │
│     │  wasabi [float]   │       │
│     └───────────────────┘       │
├──────────────────┬──────────────┤
│  Code            │  htop [right]│
└──────────────────┴──────────────┘
```

## License

MIT License
