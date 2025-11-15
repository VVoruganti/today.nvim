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

### Template placeholders

Templates support dynamic date and time placeholders. Use `{{%...}}` with the
desired format string and it will be replaced when a note is created.

```markdown
# Journal for {{%YYYY-mm-dd}}
Created at {{%HH:%M}} ({{%A}})
```

Common patterns are translated to their `strftime` equivalents. The following
named shortcuts are also provided:

* `{{%DATE}}` → `2024-03-14`
* `{{%TIME}}` → `21:45`
* `{{%DATETIME}}` → `2024-03-14 21:45`

For minutes and other advanced tokens you can still embed `strftime` specifiers,
e.g. `{{%HH:%M}}`. Any unknown pattern is left untouched so templates remain
readable.

## LICENSE

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
