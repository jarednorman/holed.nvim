-- Built-in highlight groups: editor UI, legacy syntax, treesitter, LSP,
-- diagnostics. Plugin groups live in plugins/*.lua.
---@param c HoledTheme
---@param styles HoledStyles
---@return table<string, vim.api.keyset.highlight>
return function(c, styles)
  local function with(spec, style)
    return vim.tbl_extend("force", spec, style or {})
  end

  local groups = {
    -- ----------------------------------------------------------------------
    -- Editor UI (:h highlight-groups)
    -- ----------------------------------------------------------------------
    Normal = { fg = c.fg, bg = c.bg }, -- Normal text
    NormalNC = { link = "Normal" }, -- Normal text in non-current windows
    NormalFloat = { fg = c.fg, bg = c.bg1 }, -- Normal text in floating windows
    FloatBorder = { fg = c.bg3, bg = c.bg1 }, -- Border of floating windows
    FloatTitle = { fg = c.fg_bright, bg = c.bg1, bold = true }, -- Title of floating windows
    FloatFooter = { fg = c.fg_dim, bg = c.bg1 }, -- Footer of floating windows
    ColorColumn = { bg = c.bg2 }, -- Columns set with 'colorcolumn'
    Conceal = { fg = c.fg_dim }, -- Placeholder characters substituted for concealed text
    Cursor = { fg = c.bg, bg = c.fg }, -- Character under the cursor
    lCursor = { link = "Cursor" }, -- Character under the cursor when language-mapping is used
    CursorIM = { link = "Cursor" }, -- Like Cursor, but used when in IME mode
    TermCursor = { link = "Cursor" }, -- Cursor in a focused terminal
    CursorColumn = { link = "CursorLine" }, -- Screen column of the cursor when 'cursorcolumn' is set
    CursorLine = { bg = c.bg1 }, -- Screen line of the cursor when 'cursorline' is set
    Directory = { fg = c.fun }, -- Directory names and other special names in listings
    DiffAdd = { bg = c.diff_add }, -- Diff mode: added line
    DiffChange = { bg = c.diff_change }, -- Diff mode: changed line
    DiffDelete = { fg = c.nontext, bg = c.diff_delete }, -- Diff mode: deleted line
    DiffText = { fg = c.bg, bg = c.diff_text }, -- Diff mode: changed text within a changed line
    DiffTextAdd = { link = "DiffText" }, -- Diff mode: added text within a changed line
    EndOfBuffer = { link = "NonText" }, -- Filler lines (~) after the end of the buffer
    ErrorMsg = { fg = c.error }, -- Error messages on the command line
    WinSeparator = { fg = c.bg3 }, -- Separators between window splits
    VertSplit = { link = "WinSeparator" },
    Folded = { fg = c.fg_dim, bg = c.bg2 }, -- Line used for closed folds
    FoldColumn = { link = "SignColumn" }, -- 'foldcolumn'
    SignColumn = { fg = c.nontext }, -- Column where signs are displayed
    IncSearch = { fg = c.bg, bg = c.cursearch }, -- 'incsearch' highlighting; also :s///c replacement text
    CurSearch = { link = "IncSearch" }, -- Current match for the last search pattern
    Substitute = { link = "IncSearch" }, -- :substitute replacement text highlighting
    LineNr = { fg = c.nontext }, -- Line number for :number and :# commands
    LineNrAbove = { link = "LineNr" },
    LineNrBelow = { link = "LineNr" },
    CursorLineNr = { fg = c.fg_bright }, -- Like LineNr when 'cursorline' is set for the cursor line
    CursorLineFold = { link = "FoldColumn" },
    CursorLineSign = { link = "SignColumn" },
    MatchParen = { bg = c.bg3, bold = true }, -- Paired bracket under the cursor and its match
    ModeMsg = { fg = c.fg_dim, bold = true }, -- 'showmode' message (e.g. -- INSERT --)
    MsgArea = { link = "Normal" }, -- Area for messages and command line
    MsgSeparator = { link = "WinSeparator" }, -- Separator for scrolled messages
    MoreMsg = { fg = c.fun }, -- more-prompt
    NonText = { fg = c.nontext }, -- '@' at the end of the window and other characters that do not exist in the text
    Pmenu = { fg = c.fg, bg = c.bg1 }, -- Popup menu: normal item
    PmenuSel = { fg = c.fg_bright, bg = c.bg3 }, -- Popup menu: selected item
    PmenuKind = { fg = c.type, bg = c.bg1 }, -- Popup menu: normal item kind
    PmenuKindSel = { fg = c.type, bg = c.bg3 }, -- Popup menu: selected item kind
    PmenuExtra = { fg = c.fg_dim, bg = c.bg1 }, -- Popup menu: normal item extra text
    PmenuExtraSel = { fg = c.fg_dim, bg = c.bg3 }, -- Popup menu: selected item extra text
    PmenuMatch = { fg = c.fg_bright, bg = c.bg1, bold = true }, -- Popup menu: matched text in normal item
    PmenuMatchSel = { fg = c.fg_bright, bg = c.bg3, bold = true }, -- Popup menu: matched text in selected item
    PmenuSbar = { bg = c.bg2 }, -- Popup menu: scrollbar
    PmenuThumb = { bg = c.bg3 }, -- Popup menu: thumb of the scrollbar
    ComplMatchIns = { fg = c.fg_dim }, -- Matched text of the currently inserted completion
    Question = { fg = c.fun }, -- hit-enter prompt and yes/no questions
    QuickFixLine = { bg = c.bg2 }, -- Current quickfix item in the quickfix window
    Search = { fg = c.bg, bg = c.search }, -- Last search pattern highlighting
    SnippetTabstop = { bg = c.bg2 }, -- Tabstops in snippets
    SpecialKey = { link = "NonText" }, -- Unprintable characters: text displayed differently from what it really is
    SpellBad = { sp = c.error, undercurl = true }, -- Word that is not recognized by the spellchecker
    SpellCap = { sp = c.warn, undercurl = true }, -- Word that should start with a capital
    SpellLocal = { sp = c.hint, undercurl = true }, -- Word that is recognized as one used in another region
    SpellRare = { sp = c.info, undercurl = true }, -- Word that is recognized as one that is hardly ever used
    StatusLine = { fg = c.fg, bg = c.bg1 }, -- Status line of current window
    StatusLineNC = { fg = c.nontext, bg = c.bg1 }, -- Status lines of not-current windows
    StatusLineTerm = { link = "StatusLine" },
    StatusLineTermNC = { link = "StatusLineNC" },
    TabLine = { fg = c.fg_dim, bg = c.bg1 }, -- Tab pages line, not active tab page label
    TabLineFill = { bg = c.bg1 }, -- Tab pages line, where there are no labels
    TabLineSel = { fg = c.fg_bright, bg = c.bg, bold = true }, -- Tab pages line, active tab page label
    Title = { fg = c.fg_bright, bold = true }, -- Titles for output from :set all, :autocmd etc.
    Visual = { bg = c.bg2 }, -- Visual mode selection
    VisualNOS = { link = "Visual" }, -- Visual mode selection when vim is "Not Owning the Selection"
    WarningMsg = { fg = c.warn }, -- Warning messages
    Whitespace = { link = "NonText" }, -- "nbsp", "space", "tab", "multispace", "lead" and "trail" in 'listchars'
    WildMenu = { link = "PmenuSel" }, -- Current match in 'wildmenu' completion
    WinBar = { fg = c.fg, bold = true }, -- Window bar of current window
    WinBarNC = { fg = c.nontext }, -- Window bar of not-current windows

    -- Quickfix buffer syntax
    qfFileName = { fg = c.fun },
    qfLineNr = { fg = c.fg_dim },
    qfSeparator = { fg = c.punct },
    qfError = { link = "DiagnosticError" },

    -- Netrw
    netrwDir = { link = "Directory" },
    netrwClassify = { link = "Directory" },
    netrwExe = { fg = c.string },
    netrwSymLink = { fg = c.link },
    netrwLink = { fg = c.link },
    netrwMarkFile = { bg = c.bg2 },
    netrwTreeBar = { fg = c.nontext },
    netrwComment = { link = "Comment" },
    netrwCmdNote = { link = "Comment" },
    netrwHelpCmd = { fg = c.keyword },
    netrwVersion = { fg = c.fg_dim },
    netrwList = { fg = c.fg_dim },
    netrwHidePat = { fg = c.fg_dim },
    netrwPlain = { link = "Normal" },

    -- ----------------------------------------------------------------------
    -- Legacy syntax (:h group-name). Rendered on top of treesitter when
    -- regex syntax is kept on, so every group is covered.
    -- ----------------------------------------------------------------------
    Comment = with({ fg = c.comment }, styles.comments), -- Any comment
    Constant = { fg = c.constant }, -- Any constant
    String = { fg = c.string }, -- A string constant
    Character = { link = "String" }, -- A character constant
    Number = { fg = c.number }, -- A number constant
    Boolean = { fg = c.constant }, -- A boolean constant
    Float = { link = "Number" }, -- A floating point constant
    Identifier = { fg = c.fg }, -- Any variable name
    Function = with({ fg = c.fun }, styles.functions), -- Function name (also: methods for classes)
    Statement = with({ fg = c.keyword }, styles.keywords), -- Any statement
    Conditional = { link = "Statement" }, -- if, then, else, endif, switch, etc.
    Repeat = { link = "Statement" }, -- for, do, while, etc.
    Label = { link = "Statement" }, -- case, default, etc.
    Operator = { fg = c.operator }, -- "sizeof", "+", "*", etc.
    Keyword = { link = "Statement" }, -- Any other keyword
    Exception = { link = "Statement" }, -- try, catch, throw
    PreProc = { fg = c.preproc }, -- Generic preprocessor
    Include = { link = "PreProc" }, -- Preprocessor #include
    Define = { link = "PreProc" }, -- Preprocessor #define
    Macro = { link = "PreProc" }, -- Same as Define
    PreCondit = { link = "PreProc" }, -- Preprocessor #if, #else, #endif, etc.
    Type = with({ fg = c.type }, styles.types), -- int, long, char, etc.
    StorageClass = { link = "Type" }, -- static, register, volatile, etc.
    Structure = { link = "Type" }, -- struct, union, enum, etc.
    Typedef = { link = "Type" }, -- A typedef
    Special = { fg = c.special }, -- Any special symbol
    SpecialChar = { link = "Special" }, -- Special character in a constant
    Tag = { fg = c.preproc }, -- You can use CTRL-] on this
    Delimiter = { fg = c.punct }, -- Character that needs attention
    SpecialComment = { fg = c.fg_dim }, -- Special things inside a comment
    Debug = { link = "Special" }, -- Debugging statements
    Underlined = { underline = true }, -- Text that stands out, HTML links
    Ignore = { fg = c.nontext }, -- Left blank, hidden
    Error = { fg = c.error }, -- Any erroneous construct
    Todo = { fg = c.bg, bg = c.info, bold = true }, -- TODO FIXME XXX
    Added = { fg = c.added }, -- Added line in a diff
    Changed = { fg = c.changed }, -- Changed line in a diff
    Removed = { fg = c.removed }, -- Removed line in a diff

    -- diff syntax (fugitive, :Git, patch files)
    diffAdded = { link = "Added" },
    diffRemoved = { link = "Removed" },
    diffChanged = { link = "Changed" },
    diffLine = { fg = c.info },
    diffFile = { fg = c.fg_bright, bold = true },
    diffIndexLine = { fg = c.fg_dim },
    diffOldFile = { fg = c.removed },
    diffNewFile = { fg = c.added },
    diffSubname = { fg = c.fg },
    diffComment = { link = "Comment" },

    -- help syntax (when treesitter vimdoc is unavailable)
    helpHeadline = { link = "Title" },
    helpHeader = { link = "Title" },
    helpSectionDelim = { fg = c.nontext },
    helpHyperTextJump = { fg = c.link },
    helpHyperTextEntry = { fg = c.attribute },
    helpExample = { fg = c.string },
    helpCommand = { fg = c.string },
    helpOption = { fg = c.constant },
    helpSpecial = { fg = c.special },

    -- markdown syntax (when treesitter markdown is unavailable)
    markdownH1 = { link = "@markup.heading.1" },
    markdownH2 = { link = "@markup.heading.2" },
    markdownH3 = { link = "@markup.heading.3" },
    markdownH4 = { link = "@markup.heading.4" },
    markdownH5 = { link = "@markup.heading.5" },
    markdownH6 = { link = "@markup.heading.6" },
    markdownHeadingDelimiter = { fg = c.nontext },
    markdownHeadingRule = { fg = c.nontext },
    markdownRule = { fg = c.nontext },
    markdownCode = { link = "@markup.raw" },
    markdownCodeBlock = { link = "@markup.raw.block" },
    markdownCodeDelimiter = { fg = c.nontext },
    markdownUrl = { link = "@markup.link.url" },
    markdownLinkText = { link = "@markup.link.label" },
    markdownLinkDelimiter = { fg = c.punct },
    markdownListMarker = { link = "@markup.list" },
    markdownOrderedListMarker = { link = "@markup.list" },
    markdownBold = { link = "@markup.strong" },
    markdownItalic = { link = "@markup.italic" },
    markdownBlockquote = { link = "@markup.quote" },

    -- ----------------------------------------------------------------------
    -- Treesitter (:h treesitter-highlight-groups). Only captures whose colour
    -- differs from Neovim's default link.
    -- ----------------------------------------------------------------------
    ["@variable"] = { fg = c.fg },
    ["@variable.builtin"] = { fg = c.builtin },
    ["@variable.parameter"] = { fg = c.fg },
    ["@variable.member"] = { fg = c.fg },
    ["@constant.builtin"] = { fg = c.builtin },
    ["@string.escape"] = { fg = c.special },
    ["@string.regexp"] = { fg = c.special },
    ["@string.special.symbol"] = { fg = c.attribute },
    ["@string.special.url"] = { fg = c.link, underline = true },
    ["@character.special"] = { link = "Special" },
    ["@attribute"] = { fg = c.attribute },
    ["@attribute.builtin"] = { link = "@attribute" },
    ["@function.builtin"] = { fg = c.builtin },
    ["@constructor"] = { fg = c.type },
    ["@operator"] = { fg = c.operator },
    ["@punctuation.delimiter"] = { fg = c.punct },
    ["@punctuation.bracket"] = { fg = c.punct },
    ["@punctuation.special"] = { fg = c.special },
    ["@tag"] = { fg = c.preproc },
    ["@tag.builtin"] = { link = "@tag" },
    ["@tag.attribute"] = { fg = c.attribute },
    ["@tag.delimiter"] = { fg = c.punct },
    ["@type.builtin"] = { fg = c.builtin },
    ["@comment.todo"] = { link = "Todo" },
    ["@comment.note"] = { fg = c.bg, bg = c.hint, bold = true },
    ["@comment.warning"] = { fg = c.bg, bg = c.warn, bold = true },
    ["@comment.error"] = { fg = c.bg, bg = c.error, bold = true },
    ["@markup.strong"] = { bold = true },
    ["@markup.italic"] = { italic = true },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.underline"] = { underline = true },
    ["@markup.heading"] = { fg = c.fg_bright, bold = true },
    ["@markup.heading.1"] = { fg = c.h1, bold = true },
    ["@markup.heading.2"] = { fg = c.h2, bold = true },
    ["@markup.heading.3"] = { fg = c.h3, bold = true },
    ["@markup.heading.4"] = { fg = c.h4, bold = true },
    ["@markup.heading.5"] = { fg = c.h5, bold = true },
    ["@markup.heading.6"] = { fg = c.h6, bold = true },
    ["@markup.quote"] = { fg = c.fg_dim },
    ["@markup.math"] = { fg = c.special },
    ["@markup.link"] = { fg = c.fun },
    ["@markup.link.label"] = { fg = c.fun },
    ["@markup.link.url"] = { fg = c.link, underline = true },
    ["@markup.raw"] = { fg = c.string },
    ["@markup.raw.block"] = { fg = c.fg },
    ["@markup.list"] = { fg = c.punct },
    ["@markup.list.checked"] = { fg = c.added },
    ["@markup.list.unchecked"] = { fg = c.fg_dim },
    ["@diff.plus"] = { link = "Added" },
    ["@diff.minus"] = { link = "Removed" },
    ["@diff.delta"] = { link = "Changed" },

    -- ----------------------------------------------------------------------
    -- LSP semantic tokens (:h lsp-semantic-highlight) and client UI
    -- ----------------------------------------------------------------------
    ["@lsp.type.variable"] = {}, -- let treesitter decide
    ["@lsp.type.comment"] = {}, -- let treesitter decide
    ["@lsp.typemod.variable.readonly"] = { link = "Constant" },
    ["@lsp.typemod.variable.global"] = { link = "Constant" },
    ["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
    ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
    ["@lsp.typemod.method.defaultLibrary"] = { link = "@function.builtin" },
    ["@lsp.typemod.class.defaultLibrary"] = { link = "@type.builtin" },
    ["@lsp.typemod.type.defaultLibrary"] = { link = "@type.builtin" },
    LspReferenceText = { bg = c.bg2 },
    LspReferenceRead = { link = "LspReferenceText" },
    LspReferenceWrite = { link = "LspReferenceText" },
    LspReferenceTarget = { link = "LspReferenceText" },
    LspInlayHint = { fg = c.nontext },
    LspCodeLens = { fg = c.nontext },
    LspCodeLensSeparator = { link = "LspCodeLens" },
    LspSignatureActiveParameter = { fg = c.fg_bright, bold = true },

    -- ----------------------------------------------------------------------
    -- Diagnostics (:h diagnostic-highlights)
    -- ----------------------------------------------------------------------
    DiagnosticError = { fg = c.error },
    DiagnosticWarn = { fg = c.warn },
    DiagnosticInfo = { fg = c.info },
    DiagnosticHint = { fg = c.hint },
    DiagnosticOk = { fg = c.ok },
    DiagnosticVirtualTextError = { fg = c.error, bg = c.error_bg },
    DiagnosticVirtualTextWarn = { fg = c.warn, bg = c.warn_bg },
    DiagnosticVirtualTextInfo = { fg = c.info, bg = c.info_bg },
    DiagnosticVirtualTextHint = { fg = c.hint, bg = c.hint_bg },
    DiagnosticVirtualTextOk = { fg = c.ok, bg = c.ok_bg },
    DiagnosticVirtualLinesError = { link = "DiagnosticError" },
    DiagnosticVirtualLinesWarn = { link = "DiagnosticWarn" },
    DiagnosticVirtualLinesInfo = { link = "DiagnosticInfo" },
    DiagnosticVirtualLinesHint = { link = "DiagnosticHint" },
    DiagnosticVirtualLinesOk = { link = "DiagnosticOk" },
    DiagnosticUnderlineError = { sp = c.error, undercurl = true },
    DiagnosticUnderlineWarn = { sp = c.warn, undercurl = true },
    DiagnosticUnderlineInfo = { sp = c.info, undercurl = true },
    DiagnosticUnderlineHint = { sp = c.hint, undercurl = true },
    DiagnosticUnderlineOk = { sp = c.ok, undercurl = true },
    DiagnosticFloatingError = { link = "DiagnosticError" },
    DiagnosticFloatingWarn = { link = "DiagnosticWarn" },
    DiagnosticFloatingInfo = { link = "DiagnosticInfo" },
    DiagnosticFloatingHint = { link = "DiagnosticHint" },
    DiagnosticFloatingOk = { link = "DiagnosticOk" },
    DiagnosticSignError = { link = "DiagnosticError" },
    DiagnosticSignWarn = { link = "DiagnosticWarn" },
    DiagnosticSignInfo = { link = "DiagnosticInfo" },
    DiagnosticSignHint = { link = "DiagnosticHint" },
    DiagnosticSignOk = { link = "DiagnosticOk" },
    DiagnosticDeprecated = { strikethrough = true },
    DiagnosticUnnecessary = { fg = c.fg_dim },
  }

  return groups
end
