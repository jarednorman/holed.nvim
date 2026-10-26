-- github/copilot.vim
return function(c)
  return {
    CopilotSuggestion = { fg = c.nontext, italic = true },
    CopilotAnnotation = { fg = c.fg_dim },
  }
end
