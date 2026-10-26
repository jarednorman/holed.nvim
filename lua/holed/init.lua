local M = {}

---@class HoledStyles
---@field comments vim.api.keyset.highlight
---@field keywords vim.api.keyset.highlight
---@field functions vim.api.keyset.highlight
---@field types vim.api.keyset.highlight

---@class HoledConfig
---@field styles HoledStyles Extra attributes merged into the matching groups.
---@field on_highlights fun(groups: table<string, vim.api.keyset.highlight>, c: HoledTheme) Mutate groups before they are applied.
---@field terminal_colors boolean Set vim.g.terminal_color_0..15.

---@type HoledConfig
local defaults = {
  styles = {
    comments = { italic = true },
    keywords = {},
    functions = {},
    types = {},
  },
  on_highlights = function(_, _) end,
  terminal_colors = true,
}

M.config = vim.deepcopy(defaults)

---@param opts HoledConfig|nil
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
end

function M.load()
  if vim.g.colors_name then
    vim.cmd("hi clear")
  end
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end
  -- Clear colors_name first: changing 'background' while a scheme is named
  -- would reload that scheme.
  vim.g.colors_name = nil
  vim.o.background = "dark"
  vim.o.termguicolors = true
  vim.g.colors_name = "holed"
  require("holed.highlights").apply(M.config)
end

return M
