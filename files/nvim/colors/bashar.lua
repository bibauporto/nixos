local M = {}

function M.setup()
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  vim.o.background = "dark"
  vim.o.termguicolors = true
  vim.g.colors_name = "bashar"

  local colors = {
    bg = "#000000",
    fg = "#abb2bf",
    comment = "#525252",
    red = "#e40101",
    orange = "#FFA657",
    yellow = "#e6ed5a", -- from keyword.control.conditional
    green = "#5DB844",
    cyan = "#00AAAA",
    blue = "#79C0FF",
    light_blue = "#A5D6FF",
    purple = "#b180d7",
    dark_grey = "#21252b",
    light_grey = "#cccccc",
    white = "#fcfcfc",
    line_bg = "#111214",
    selection = "#264f78",
    none = "NONE",
  }

  local highlights = {
    -- Editor Base
    Normal = { fg = colors.fg, bg = colors.bg },
    NormalFloat = { fg = colors.fg, bg = colors.dark_grey },
    FloatBorder = { fg = colors.blue, bg = colors.dark_grey },
    Pmenu = { fg = colors.fg, bg = colors.dark_grey },
    PmenuSel = { fg = colors.white, bg = colors.selection },
    Cursor = { fg = colors.bg, bg = colors.white },
    CursorLine = { bg = colors.line_bg },
    LineNr = { fg = "#495162" },
    CursorLineNr = { fg = colors.fg, bold = true },
    VertSplit = { fg = "#23252c", bg = colors.bg },
    WinSeparator = { fg = "#23252c", bg = colors.bg },
    StatusLine = { fg = colors.fg, bg = colors.dark_grey },
    StatusLineNC = { fg = colors.comment, bg = colors.bg },
    SignColumn = { bg = colors.bg },
    FoldColumn = { fg = colors.comment, bg = colors.bg },
    Folded = { fg = colors.comment, bg = colors.line_bg },
    Search = { fg = colors.white, bg = colors.selection },
    IncSearch = { fg = colors.bg, bg = colors.orange },
    Visual = { bg = "#677696" }, -- editor.selectionBackground
    MatchParen = { fg = colors.cyan, bold = true, underline = true },

    -- Syntax
    Comment = { fg = colors.comment, italic = true },
    Constant = { fg = colors.white },
    String = { fg = colors.light_grey },
    Character = { fg = colors.red },
    Number = { fg = "#b2dbff" },
    Boolean = { fg = "#916403" },
    Float = { fg = "#b2dbff" },
    Identifier = { fg = colors.blue },
    Function = { fg = colors.orange },
    Statement = { fg = colors.red },
    Conditional = { fg = colors.yellow },
    Repeat = { fg = colors.yellow },
    Label = { fg = colors.red },
    Operator = { fg = colors.light_grey },
    Keyword = { fg = colors.red },
    Exception = { fg = colors.red },
    PreProc = { fg = colors.red },
    Include = { fg = colors.red },
    Define = { fg = colors.red },
    Macro = { fg = colors.red },
    Type = { fg = colors.cyan },
    StorageClass = { fg = colors.red },
    Structure = { fg = colors.cyan },
    Typedef = { fg = colors.cyan },
    Special = { fg = colors.blue },
    SpecialChar = { fg = colors.red },
    Tag = { fg = colors.green },
    Delimiter = { fg = colors.fg },
    Debug = { fg = colors.red },
    Underlined = { underline = true, fg = colors.blue },
    Ignore = { fg = colors.comment },
    Error = { fg = colors.red },
    Todo = { fg = colors.orange, bold = true },

    -- TreeSitter / Lsp
    ["@comment"] = { link = "Comment" },
    ["@none"] = { bg = "NONE", fg = "NONE" },
    ["@preproc"] = { link = "PreProc" },
    ["@define"] = { link = "Define" },
    ["@operator"] = { link = "Operator" },
    ["@punctuation.delimiter"] = { link = "Delimiter" },
    ["@punctuation.bracket"] = { link = "Delimiter" },
    ["@punctuation.special"] = { link = "Special" },
    ["@string"] = { link = "String" },
    ["@string.regex"] = { fg = colors.light_blue },
    ["@string.escape"] = { fg = "#7EE787", bold = true },
    ["@character"] = { link = "Character" },
    ["@character.special"] = { link = "SpecialChar" },
    ["@boolean"] = { link = "Boolean" },
    ["@number"] = { link = "Number" },
    ["@float"] = { link = "Float" },
    ["@function"] = { link = "Function" },
    ["@function.builtin"] = { link = "Special" },
    ["@function.call"] = { link = "Function" },
    ["@function.macro"] = { link = "Macro" },
    ["@method"] = { link = "Function" },
    ["@method.call"] = { link = "Function" },
    ["@constructor"] = { link = "Special" },
    ["@parameter"] = { fg = colors.white },
    ["@keyword"] = { link = "Keyword" },
    ["@keyword.function"] = { link = "Keyword" },
    ["@keyword.operator"] = { link = "Operator" },
    ["@keyword.return"] = { link = "Keyword" },
    ["@conditional"] = { link = "Conditional" },
    ["@repeat"] = { link = "Repeat" },
    ["@debug"] = { link = "Debug" },
    ["@label"] = { link = "Label" },
    ["@include"] = { link = "Include" },
    ["@exception"] = { link = "Exception" },
    ["@type"] = { link = "Type" },
    ["@type.builtin"] = { link = "Type" },
    ["@type.definition"] = { link = "Typedef" },
    ["@type.qualifier"] = { link = "Type" },
    ["@storageclass"] = { link = "StorageClass" },
    ["@attribute"] = { link = "PreProc" },
    ["@field"] = { fg = colors.white },
    ["@property"] = { fg = colors.blue },
    ["@variable"] = { fg = colors.blue },
    ["@variable.builtin"] = { link = "Special" },
    ["@constant"] = { link = "Constant" },
    ["@constant.builtin"] = { link = "Constant" },
    ["@constant.macro"] = { link = "Define" },
    ["@namespace"] = { link = "Include" },
    ["@symbol"] = { link = "Identifier" },
    ["@text"] = { link = "Normal" },
    ["@text.strong"] = { bold = true },
    ["@text.emphasis"] = { italic = true },
    ["@text.underline"] = { underline = true },
    ["@text.strike"] = { strikethrough = true },
    ["@text.title"] = { link = "Title" },
    ["@text.literal"] = { link = "String" },
    ["@text.uri"] = { link = "Underlined" },
    ["@tag"] = { link = "Tag" },
    ["@tag.attribute"] = { fg = colors.white },
    ["@tag.delimiter"] = { link = "Delimiter" },
    
    -- Diagnostics
    DiagnosticError = { fg = colors.red },
    DiagnosticWarn = { fg = colors.yellow },
    DiagnosticInfo = { fg = colors.blue },
    DiagnosticHint = { fg = colors.cyan },
    DiagnosticUnderlineError = { underline = true, sp = colors.red },
    DiagnosticUnderlineWarn = { underline = true, sp = colors.yellow },
    DiagnosticUnderlineInfo = { underline = true, sp = colors.blue },
    DiagnosticUnderlineHint = { underline = true, sp = colors.cyan },

    -- Plugins
    -- Flash.nvim (Addressing user request)
    FlashBackdrop = { fg = colors.comment },
    FlashLabel = { bg = colors.red, fg = colors.white, bold = true },
    FlashMatch = { bg = colors.selection, fg = colors.light_grey },
    FlashCurrent = { bg = colors.orange, fg = colors.bg, bold = true },
    
    -- NeoTree
    NeoTreeNormal = { fg = colors.fg, bg = colors.bg },
    NeoTreeNormalNC = { fg = colors.fg, bg = colors.bg },
    NeoTreeRootName = { fg = colors.blue, bold = true },
    NeoTreeGitAdded = { fg = "#109868" },
    NeoTreeGitDeleted = { fg = "#9a353d" },
    NeoTreeGitModified = { fg = "#e2c08d" },
    NeoTreeGitUntracked = { fg = "#73c991" },
    
    -- Telescope
    TelescopeBorder = { fg = colors.dark_grey, bg = colors.dark_grey },
    TelescopeNormal = { fg = colors.fg, bg = colors.dark_grey },
    TelescopePromptBorder = { fg = colors.selection, bg = colors.selection },
    TelescopePromptNormal = { fg = colors.white, bg = colors.selection },
    TelescopePromptPrefix = { fg = colors.red, bg = colors.selection },
    TelescopeSelection = { fg = colors.white, bg = colors.selection },
    
    -- LazyGit
    LazyGitFloat = { fg = colors.fg, bg = colors.dark_grey },
    LazyGitBorder = { fg = colors.blue, bg = colors.dark_grey },

    -- WhichKey
    WhichKey = { fg = colors.blue },
    WhichKeyDesc = { fg = colors.fg },
    WhichKeyGroup = { fg = colors.orange },
    WhichKeySeparator = { fg = colors.comment },
    WhichKeyFloat = { bg = colors.dark_grey },

    -- Lazy.nvim
    LazyNormal = { bg = colors.dark_grey, fg = colors.fg },
    LazyBorder = { fg = colors.blue, bg = colors.dark_grey },

    -- Mason
    MasonNormal = { bg = colors.dark_grey, fg = colors.fg },
    
    -- Cmp / Blink
    CmpItemAbbr = { fg = colors.fg },
    CmpItemAbbrDeprecated = { fg = colors.comment, strikethrough = true },
    CmpItemAbbrMatch = { fg = colors.blue, bold = true },
    CmpItemAbbrMatchFuzzy = { fg = colors.blue, bold = true },
    CmpItemKind = { fg = colors.cyan },
    CmpItemMenu = { fg = colors.comment },

    -- Notify
    NotifyINFOBorder = { fg = colors.blue },
    NotifyINFOTitle = { fg = colors.blue },
    NotifyINFOIcon = { fg = colors.blue },
    NotifyWARNBorder = { fg = colors.orange },
    NotifyWARNTitle = { fg = colors.orange },
    NotifyWARNIcon = { fg = colors.orange },
    NotifyERRORBorder = { fg = colors.red },
    NotifyERRORTitle = { fg = colors.red },
    NotifyERRORIcon = { fg = colors.red },

    -- BufferLine
    BufferLineFill = { bg = colors.bg },
    BufferLineBackground = { fg = colors.comment, bg = colors.bg },
    BufferLineBufferVisible = { fg = colors.comment, bg = colors.bg },
    BufferLineBufferSelected = { fg = colors.fg, bg = colors.line_bg, bold = true },
    BufferLineIndicatorSelected = { fg = colors.blue, bg = colors.line_bg },
    
    -- Noice
    NoiceCmdlinePopupBorder = { fg = colors.blue, bg = colors.dark_grey },
    NoiceCmdlinePopupTitle = { fg = colors.orange, bg = colors.dark_grey },
  }

  for group, hl in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, hl)
  end
end

M.setup()

return M

