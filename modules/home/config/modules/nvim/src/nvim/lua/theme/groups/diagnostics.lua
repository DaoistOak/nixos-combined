-- Diagnostics, LSP inlines and diffs.
--
-- The severity ramp is built from the palette's red/orange/blue/green slots and
-- each severity only ever uses its own slot, so signs, virtual text, underlines
-- and floating windows stay consistent with each other.

local color = require("theme.color")

return function(c, hl)
  local severities = {
    Error = { fg = c.base08, sep = c.base08 },
    Warn = { fg = c.base09, sep = c.base09 },
    Info = { fg = c.blue, sep = c.blue },
    Hint = { fg = c.base0C, sep = c.base0C },
    Ok = { fg = c.base0B, sep = c.base0B },
  }

  for name, s in pairs(severities) do
    hl["DiagnosticSign" .. name]({ fg = s.fg })
    hl["Diagnostic" .. name .. "Sign"]({ fg = s.fg })
    hl["Diagnostic" .. name .. "VirtualText"]({ fg = s.fg })
    hl["Diagnostic" .. name .. "VirtualLines"]({ fg = s.fg })
    hl["Diagnostic" .. name .. "Floating"]({ fg = s.fg })
    hl["Diagnostic" .. name .. "Underline"]({ sp = s.fg, undercurl = true })
    hl["Diagnostic" .. name .. "UnderlineError"]({ sp = s.fg, undercurl = true })
    hl["Diagnostic" .. name .. "UnderlineWarn"]({ sp = s.fg, undercurl = true })
    hl["Diagnostic" .. name .. "UnderlineInfo"]({ sp = s.fg, undercurl = true })
    hl["Diagnostic" .. name .. "UnderlineHint"]({ sp = s.fg, undercurl = true })
  end

  hl.DiagnosticVirtualText({ fg = c.fg.dim })
  hl.DiagnosticFloating({ fg = c.fg.base })
  hl.DiagnosticUnderlineError({ sp = c.base08, undercurl = true })
  hl.DiagnosticUnpack({ bg = "NONE" })

  -- lspinfo
  hl.LspInfoBorder({ fg = c.overlay0, bg = c.bg.raised })
  hl.LspInfoTitle({ fg = c.accent, bg = c.bg.raised, bold = true })
  hl.LspInfoFiletype({ fg = c.fg.dim })
  hl.LspInfoSymbol({ fg = c.blue })

  -- Diff: a light tint of the severity colour rather than a solid block, so
  -- inserted and removed text stays readable.
  local tint = function(fg, amount)
    return color.blend(fg, c.bg.base, amount)
  end
  hl.DiffAdd({ bg = tint(c.base0B, 0.16) })
  hl.DiffChange({ bg = tint(c.base0A, 0.14) })
  hl.DiffDelete({ bg = tint(c.base08, 0.16) })
  hl.DiffText({ bg = tint(c.base0A, 0.34) })
  hl.DiffAddAsDelete({ bg = tint(c.base0B, 0.16) })
  hl.DiffDeleteAsAdd({ bg = tint(c.base08, 0.16) })
  hl.diffAdded({ fg = c.base0B })
  hl.diffRemoved({ fg = c.base08 })
  hl.diffChanged({ fg = c.base0A })
  hl.diffFile({ fg = c.blue })
  hl.diffOldFile({ fg = c.base0B })
  hl.diffNewFile({ fg = c.base0B })
  hl.diffLine({ fg = c.overlay0 })
  hl.foldedColumn({ fg = c.accent, bg = c.bg.raised })
  hl.foldedLine({ fg = c.accent, bg = c.bg.raised })
end
