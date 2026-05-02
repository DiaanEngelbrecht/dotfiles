require("transparent").setup({
  groups = { -- table: default groups
    'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
    'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
    'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
    'SignColumn', 'CursorLineNr', 'EndOfBuffer',
  },
  extra_groups = {
    -- Floats / popups
    "NormalFloat", "FloatBorder", "FloatTitle",
    -- nvim-tree
    "NvimTreeNormal", "NvimTreeNormalNC", "NvimTreeNormalFloat",
    "NvimTreeEndOfBuffer", "NvimTreeWinSeparator", "NvimTreeStatusLine",
    "NvimTreeStatusLineNC",
    -- Splits / status
    "WinSeparator", "VertSplit", "StatusLine", "StatusLineNC",
    "TabLine", "TabLineFill", "TabLineSel",
    -- Telescope
    "TelescopeNormal", "TelescopeBorder", "TelescopePromptNormal",
    "TelescopePromptBorder", "TelescopeResultsNormal", "TelescopeResultsBorder",
    "TelescopePreviewNormal", "TelescopePreviewBorder", "TelescopePromptTitle",
    "TelescopeResultsTitle", "TelescopePreviewTitle",
    -- Diagnostics floats
    "DiagnosticFloatingError", "DiagnosticFloatingWarn",
    "DiagnosticFloatingInfo", "DiagnosticFloatingHint",
    -- Notify / which-key / lazy / mason
    "NotifyBackground", "WhichKeyFloat", "LazyNormal", "MasonNormal",
  },
  exclude_groups = {}, -- table: groups you don't want to clear
})
