-- Core editor surface: the buffer, gutter, cursor, tabline and window chrome.
-- Everything here is what you see with an empty config, so it is the part that
-- has to look right before any plugin paints over it.

return function(c, hl)
  hl.Normal({ fg = c.fg.base, bg = c.bg.base })
  hl.NormalNC({ fg = c.fg.muted, bg = c.bg.base })
  hl.NormalFloat({ fg = c.fg.base, bg = c.bg.raised })
  hl.NormalFloatNC({ fg = c.fg.muted, bg = c.bg.raised })
  hl.NormalSB({ fg = c.fg.faint, bg = c.bg.sunken })

  -- Cursor
  hl.Cursor({ fg = c.bg.base, bg = c.accent })
  hl.lCursor({ fg = c.bg.base, bg = c.accent })
  hl.TermCursor({ fg = c.bg.base, bg = c.accent })
  hl.CursorIM({ fg = c.bg.base, bg = c.accent })
  hl.ColorColumn({ bg = c.bg.line })
  hl.CursorColumn({ bg = c.bg.line })
  hl.CursorLine({ bg = c.bg.line })
  hl.CursorLineNr({ fg = c.accent, bg = c.bg.line, bold = true })
  hl.CursorLineSign({ bg = c.bg.line })
  hl.CursorLineFold({ bg = c.bg.line })
  hl.MatchParen({ bg = c.overlay0, bold = true })
  hl.CursorMatch({ bg = c.surface2, bold = true })
  hl.CursorMatchSelect({ bg = c.overlay0 })

  -- Gutter
  hl.LineNr({ fg = c.fg.muted, bg = c.bg.base })
  hl.LineNrAbove({ fg = c.fg.muted, bg = c.bg.base })
  hl.LineNrBelow({ fg = c.fg.muted, bg = c.bg.base })
  hl.SignColumn({ fg = c.fg.dim, bg = c.bg.base })
  hl.SignColumnSB({ fg = c.fg.muted, bg = c.bg.sunken })
  hl.FoldColumn({ fg = c.fg.dim, bg = c.bg.base })
  hl.Folded({ fg = c.accent, bg = c.bg.raised, bold = true })
  hl.EndOfBuffer({ fg = c.bg.sunken, bg = c.bg.base })
  hl.NonText({ fg = c.overlay0 })
  hl.Whitespace({ fg = c.surface2 })
  hl.SpecialKey({ fg = c.overlay1 })
  hl.Conceal({ fg = c.overlay0 })
  hl.SemiTrans({ bg = c.bg.line })
  hl.QuickFixLine({ bg = c.bg.line, bold = true })
  hl.CompleteMatchIns({ fg = c.bg.base, bg = c.accent })
  hl.TrailingWhitespace({ bg = c.surface2 })
  hl.TrailingCB({ fg = c.bg.base, bg = c.base0A })
  hl.SpellBad({ sp = c.base08, undercurl = true })
  hl.SpellCap({ sp = c.base09, undercurl = true })
  hl.SpellLocal({ sp = c.blue, undercurl = true })
  hl.SpellRare({ sp = c.mauve, undercurl = true })

  -- Selection and search
  hl.Visual({ bg = c.surface2 })
  hl.VisualNOS({ bg = c.surface2 })
  hl.Search({ bg = c.base0A, fg = c.bg.base })
  hl.IncSearch({ bg = c.base0B, fg = c.bg.base })
  hl.CurSearch({ bg = c.accent, fg = c.bg.base, bold = true })
  hl.Substitute({ bg = c.mauve, fg = c.bg.base })

  -- Messages
  hl.ModeMsg({ fg = c.fg.text, bold = true })
  hl.MsgArea({ fg = c.fg.base })
  hl.MsgSeparator({ fg = c.overlay0 })
  hl.MoreMsg({ fg = c.accent })
  hl.Prompt({ fg = c.accent })
  hl.WildMenu({ fg = c.bg.base, bg = c.surface1, bold = true })

  -- Windows and tabline
  hl.WinSeparator({ fg = c.bg.raised, bg = c.bg.base })
  hl.VertSplit({ fg = c.bg.raised, bg = c.bg.base })
  hl.Winbar({ fg = c.fg.dim, bg = c.bg.sunken })
  hl.WinbarNC({ fg = c.fg.muted, bg = c.bg.sunken })
  hl.WinbarSpecial({ fg = c.accent, bg = c.bg.sunken, bold = true })
  hl.StatusLine({ fg = c.fg.dim, bg = c.bg.raised })
  hl.StatusLineNC({ fg = c.fg.muted, bg = c.bg.raised })
  hl.TabLine({ fg = c.fg.muted, bg = c.bg.sunken })
  hl.TabLineFill({ bg = c.bg.sunken })
  hl.TabLineSel({ fg = c.fg.text, bg = c.bg.base, bold = true })
end
