-- tpope/vim-fugitive
return function(c)
  return {
    fugitiveHeader = { fg = c.fg_bright, bold = true },
    fugitiveHash = { fg = c.number },
    fugitiveSymbolicRef = { fg = c.fun },
    fugitiveSection = { link = "Title" },
    fugitiveHeading = { link = "Title" },
    fugitiveStagedHeading = { fg = c.added, bold = true },
    fugitiveStagedModifier = { fg = c.added },
    fugitiveUnstagedHeading = { fg = c.changed, bold = true },
    fugitiveUnstagedModifier = { fg = c.changed },
    fugitiveUntrackedHeading = { fg = c.removed, bold = true },
    fugitiveUntrackedModifier = { fg = c.removed },
    fugitiveModifier = { fg = c.fg_dim },
    fugitiveCount = { fg = c.fg_dim },
    fugitivePreposition = { fg = c.fg_dim },
    fugitiveHunk = { fg = c.fg },
    fugitiveHelpHeader = { link = "Title" },
    fugitiveHelpTag = { fg = c.link },
    fugitiveInstruction = { fg = c.keyword },
    fugitiveStop = { fg = c.error },
    fugitiveDone = { fg = c.ok },
  }
end
