# holed

A Neovim colorscheme for OLED displays. The background is `#000000` and every
other colour is generated from a handful of OKLCH rules in `palette.rb`.

## Install

With lazy.nvim:

```lua
{
  "jarednorman/holed.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd.colorscheme("holed")
  end,
}
```

Requires Neovim 0.10 or newer and `termguicolors`, which the scheme sets.

## Options

`setup()` is optional. Defaults:

```lua
require("holed").setup({
  styles = {
    comments = { italic = true },
    keywords = {},
    functions = {},
    types = {},
  },
  -- Mutate groups before they are applied. `c` is the theme table
  -- (see lua/holed/theme.lua); every role is a hex string.
  on_highlights = function(groups, c)
    -- groups.Comment = { fg = c.fg_dim, italic = false }
    -- groups.TelescopeSelection = { link = "PmenuSel" }
  end,
  terminal_colors = true,
})
```

Call `setup()` before `colorscheme holed`.

## How it is built

- `palette.rb` is the single source of colour values: the neutral ramp, the
  accent wheel, bright and tint variants, and the 16-slot terminal mapping.
  `ruby palette.rb` previews it in the terminal.
- `make generate` renders it into `lua/holed/palette.lua` and
  `extras/ghostty/holed`. Those files are generated; do not edit them.
- `lua/holed/theme.lua` maps palette keys to named roles (`bg1`, `keyword`,
  `error`, ...). It is the only hand-written file that names a palette key.
- `lua/holed/groups.lua` defines the built-in highlight groups from roles.
- `lua/holed/plugins/*.lua` hold plugin groups, one file per plugin.

### Adding a plugin

Create `lua/holed/plugins/<name>.lua`:

```lua
-- owner/repo
return function(c)
  return {
    PluginNormal = { link = "NormalFloat" },
    PluginBorder = { link = "FloatBorder" },
    PluginSelection = { link = "PmenuSel" },
    PluginMatch = { fg = c.search, bold = true },
  }
end
```

Link to built-in groups wherever one has the right look, and reach for a role
only when none does. The file is discovered automatically. Run `make check`
to catch typos in role names and link targets.

### Changing a colour

Edit the tunables at the top of `palette.rb` or the role mapping in
`theme.lua`, then `make generate && make check`.

## Ghostty

Copy `extras/ghostty/holed` to `~/.config/ghostty/themes/holed` and set
`theme = holed`.
