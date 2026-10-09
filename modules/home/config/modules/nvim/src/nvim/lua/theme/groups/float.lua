-- Chrome: floating windows, the completion menu, which-key and telescope.

return function(c, hl)
  -- Floating windows
  hl.FloatBorder({ fg = c.overlay0, bg = c.bg.raised })
  hl.FloatTitle({ fg = c.bg.base, bg = c.accent, bold = true })
  hl.FloatFooter({ fg = c.fg.dim, bg = c.bg.raised })
  hl.FloatShadow({ bg = "NONE" })
  hl.FloatShadowThrough({ bg = "NONE" })
  hl.WinShadow({ bg = "NONE" })
  hl.WinShadowThrough({ bg = "NONE" })
  hl.Title({ fg = c.accent, bold = true })
  hl.Subtitle({ fg = c.fg.dim })

  -- Completion menu
  hl.Pmenu({ fg = c.fg.base, bg = c.bg.raised })
  hl.PmenuSel({ fg = c.fg.text, bg = c.surface2, bold = true })
  hl.PmenuKind({ fg = c.blue, bg = c.bg.raised })
  hl.PmenuExtra({ fg = c.fg.faint, bg = c.bg.raised })
  hl.PmenuKindSel({ fg = c.blue, bg = c.surface2, bold = true })
  hl.PmenuExtraSel({ fg = c.fg.dim, bg = c.surface2, bold = true })
  hl.PmenuMatch({ fg = c.accent, bold = true })
  hl.PmenuMatchSel({ fg = c.accent, bg = c.surface2, bold = true })
  hl.PmenuSbar({ bg = c.bg.sunken })
  hl.PmenuThumb({ bg = c.overlay0 })

  -- which-key
  hl.WhichKey({ fg = c.accent, bold = true })
  hl.WhichKeyGroup({ fg = c.blue })
  hl.WhichKeyDesc({ fg = c.fg.base })
  hl.WhichKeySeparator({ fg = c.overlay0 })
  hl.WhichKeyFloat({ bg = c.bg.raised })
  hl.WhichKeyBorder({ fg = c.overlay0, bg = c.bg.raised })
  hl.WhichKeyValue({ fg = c.fg.dim })

  -- Telescope / fzf-lua
  hl.TelescopeNormal({ fg = c.fg.base, bg = c.bg.raised })
  hl.TelescopeBorder({ fg = c.overlay0, bg = c.bg.raised })
  hl.TelescopeTitle({ fg = c.bg.base, bg = c.accent, bold = true })
  hl.TelescopeSelection({ bg = c.surface2, bold = true })
  hl.TelescopeSelectionCaret({ fg = c.mauve, bg = c.surface2 })
  hl.TelescopePromptPrefix({ fg = c.mauve, bg = c.bg.raised })
  hl.TelescopePromptCounter({ fg = c.fg.muted })
  hl.TelescopePreviewNormal({ bg = c.bg.raised })
  hl.TelescopePreviewBorder({ fg = c.overlay0, bg = c.bg.raised })
  hl.TelescopePreviewLine({ bg = c.bg.raised })
  hl.TelescopePreviewTitle({ fg = c.bg.base, bg = c.mauve, bold = true })
  hl.TelescopeResultsTitle({ fg = c.bg.base, bg = c.blue, bold = true })
  hl.TelescopeResultsBorder({ fg = c.overlay0, bg = c.bg.raised })
  hl.TelescopeMatching({ fg = c.accent, bold = true })
  hl.TelescopeMultiSelection({ fg = c.accent })
  hl.TelescopeMultiIcon({ fg = c.accent })
end
