# Today.nvim

A Neovim plugin for quick access to daily notes.

## Features

- Quickly open today's note or notes from previous days
- Customizable note location and template
- Works out of the box with sensible defaults
- Supports count prefix for easy access to past dates

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'VVoruganti/today.nvim',
  config = function()
    require('today').setup()
  end
}
```

### Using lazy.nvim

```lua
{
  'VVoruganti/today.nvim',
  config = function()
    require('today').setup()
  end
}
```

### Using vim-plug

```vim
Plug 'VVoruganti/today.nvim'

" In your init.vim or init.lua, after loading plugins:
lua require('today').setup()
```

## Configuration

Today.nvim works out of the box with no configuration, but you can customize its behavior:

```lua
require('today').setup({
  local_root = "/path/to/your/notes",  -- Default: ~/.today
  template = "custom_template.md"      -- Default: jrnl.md
})
```

Usage

* `:Today` - Open today's note
* `:Today 5` - Open the note from 5 days ago
* `5Today` - Also opens the note from 5 days ago

You can also map the command to a key for quick access:

```lua
vim.keymap.set("n", "<leader>t", ":Today<CR>", { noremap = true, silent = true, desc = "Open today's note" })
```
With this mapping:

* `<leader>t` opens today's note
* `5<leader>t` opens the note from 5 days ago

Default Behavior
If no custom local_root is specified:

* Creates a .today directory in your home folder
* Uses a default jrnl.md template
* Organizes notes in a daily/YYYY/MM/YYYY-MM-DD.md structure

## LICENSE

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

