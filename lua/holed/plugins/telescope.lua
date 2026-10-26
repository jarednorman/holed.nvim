-- nvim-telescope/telescope.nvim
return function(c)
  return {
    TelescopeNormal = { link = "Normal" },
    TelescopeBorder = { fg = c.bg3 },
    TelescopeTitle = { fg = c.fg_bright, bold = true },
    TelescopePromptTitle = { link = "TelescopeTitle" },
    TelescopeResultsTitle = { link = "TelescopeTitle" },
    TelescopePreviewTitle = { link = "TelescopeTitle" },
    TelescopePromptPrefix = { fg = c.fun },
    TelescopePromptCounter = { fg = c.fg_dim },
    TelescopeSelection = { fg = c.fg_bright, bg = c.bg2 },
    TelescopeSelectionCaret = { fg = c.fun, bg = c.bg2 },
    TelescopeMultiSelection = { fg = c.constant },
    TelescopeMultiIcon = { fg = c.constant },
    TelescopeMatching = { fg = c.search, bold = true },
    TelescopeResultsComment = { link = "Comment" },
    TelescopeResultsLineNr = { link = "LineNr" },
    TelescopeResultsDiffAdd = { link = "Added" },
    TelescopeResultsDiffChange = { link = "Changed" },
    TelescopeResultsDiffDelete = { link = "Removed" },
    TelescopeResultsDiffUntracked = { fg = c.fg_dim },
    TelescopePreviewLine = { bg = c.bg2 },
    TelescopePreviewMatch = { link = "Search" },
  }
end
