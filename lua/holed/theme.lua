-- Palette keys become named roles here. This is the only hand-written file
-- that references palette keys; every highlight group reads a role.
local p = require("holed.palette")

---@class HoledTheme
local c = {
  -- Neutral ladder. One job per level.
  bg = p.black, -- Normal
  bg1 = p.gray1, -- CursorLine, StatusLine, floats, Pmenu
  bg2 = p.gray2, -- Visual, ColorColumn, Folded, QuickFixLine, list selections
  bg3 = p.gray3, -- PmenuSel, MatchParen, borders, separators
  nontext = p.gray4, -- LineNr, NonText, Whitespace, EndOfBuffer, ghost text
  fg_dim = p.gray5, -- Comment, punctuation, secondary text
  fg = p.gray6, -- Normal text
  fg_bright = p.white, -- emphasis, matches, selected items

  -- Syntax.
  keyword = p.purple,
  fun = p.blue,
  string = p.green,
  type = p.yellow,
  constant = p.orange,
  number = p.magenta,
  preproc = p.red, -- macros, imports, defines, tags
  special = p.teal, -- escapes, regex, special punctuation
  builtin = p.violet, -- self/this, builtin types, functions and constants
  attribute = p.lime, -- decorators, tag attributes, symbols
  comment = p.gray5,
  punct = p.gray5,
  operator = p.gray6,

  -- Diagnostics.
  error = p.red,
  warn = p.yellow,
  info = p.blue,
  hint = p.cyan,
  ok = p.green,
  error_bg = p.tint.red,
  warn_bg = p.tint.yellow,
  info_bg = p.tint.blue,
  hint_bg = p.tint.cyan,
  ok_bg = p.tint.green,

  -- Version control.
  added = p.green,
  changed = p.yellow,
  removed = p.red,
  diff_add = p.tint.green,
  diff_change = p.tint.yellow,
  diff_delete = p.tint.red,
  diff_text = p.mid.yellow, -- bg behind changed words; normal text on top
  diff_add_word = p.mid.green, -- bg behind added words, or fg for "+n" stats
  diff_delete_word = p.mid.red, -- bg behind removed words, or fg for "-n" stats

  -- Misc.
  search = p.yellow, -- fill; text on it is bg
  cursearch = p.orange, -- fill; text on it is bg
  link = p.cyan,
  h1 = p.blue,
  h2 = p.violet,
  h3 = p.teal,
  h4 = p.green,
  h5 = p.yellow,
  h6 = p.orange,

  -- The raw palette, for the rare group that is literally named after a
  -- colour (WhichKeyColorRed). Prefer a role.
  palette = p,
}

-- A typo in a role name would otherwise silently drop the attribute.
return setmetatable(c, {
  __index = function(_, k)
    error(("holed: unknown theme role %q"):format(tostring(k)), 2)
  end,
})
