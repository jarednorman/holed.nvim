local M = {}

-- Every lua/holed/plugins/*.lua on the runtime path, each a
-- function(c) -> { Group = spec }.
local function plugin_groups(c)
  local groups = {}
  for _, path in ipairs(vim.api.nvim_get_runtime_file("lua/holed/plugins/*.lua", true)) do
    for name, spec in pairs(dofile(path)(c)) do
      groups[name] = spec
    end
  end
  return groups
end

-- Builds the full group table without applying it. Used by apply() and by
-- check.lua.
---@param config HoledConfig
---@return table<string, vim.api.keyset.highlight>, HoledTheme
function M.build(config)
  local c = require("holed.theme")
  local groups = require("holed.groups")(c, config.styles)
  for name, spec in pairs(plugin_groups(c)) do
    groups[name] = spec
  end
  config.on_highlights(groups, c)
  return groups, c
end

---@param config HoledConfig
function M.apply(config)
  local groups, c = M.build(config)
  for name, spec in pairs(groups) do
    -- nvim_set_hl ignores everything else when link is present, so an
    -- override that adds attributes to a linked group wins over the link.
    if spec.link then
      for key in pairs(spec) do
        if key ~= "link" then
          spec.link = nil
          break
        end
      end
    end
    vim.api.nvim_set_hl(0, name, spec)
  end
  if config.terminal_colors then
    for i, hex in ipairs(c.palette.term) do
      vim.g["terminal_color_" .. (i - 1)] = hex
    end
  end
end

return M
