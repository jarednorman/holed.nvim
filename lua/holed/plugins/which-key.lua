-- folke/which-key.nvim
return function(c)
  local p = c.palette
  return {
    WhichKey = { fg = c.fun },
    WhichKeyGroup = { fg = c.keyword },
    WhichKeyDesc = { fg = c.fg },
    WhichKeySeparator = { fg = c.punct },
    WhichKeyValue = { fg = c.fg_dim },
    WhichKeyIcon = { fg = c.special },
    WhichKeyNormal = { link = "NormalFloat" },
    WhichKeyBorder = { link = "FloatBorder" },
    WhichKeyTitle = { link = "FloatTitle" },
    -- Literally named after colours; the one place the raw palette is used.
    WhichKeyColorAzure = { fg = p.cyan },
    WhichKeyColorBlue = { fg = p.blue },
    WhichKeyColorCyan = { fg = p.teal },
    WhichKeyColorGreen = { fg = p.green },
    WhichKeyColorGrey = { fg = p.gray5 },
    WhichKeyColorOrange = { fg = p.orange },
    WhichKeyColorPurple = { fg = p.purple },
    WhichKeyColorRed = { fg = p.red },
    WhichKeyColorYellow = { fg = p.yellow },
  }
end
