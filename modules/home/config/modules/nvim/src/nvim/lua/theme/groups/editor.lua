-- Base UI: signs, folds, line numbers, cursorline, splits, search, shadows.
local hl = require("theme.hl")

return function(c)
	hl.hi("Normal", { fg = c.text, bg = c.base })
	hl.hi("NormalNC", { fg = c.text, bg = c.base })
	hl.hi("SignColumn", { fg = c.subtext0 })
	hl.hi("SignColumnSB", { fg = c.overlay0 })
	hl.hi("FoldColumn", { fg = c.overlay0, bg = c.base })
	hl.hi("Folded", { fg = c.accent, bg = c.base })
	hl.set({ "LineNr", "LineNrAbove" }, { fg = c.overlay0 })
	hl.set({ "CursorLineNr", "CursorLineSign" }, { fg = c.text })
	hl.hi("CursorLineFold", { fg = c.overlay0 })
	hl.hi("NonText", { fg = c.overlay1, bg = c.surface0 })
	hl.hi("WinSeparator", { fg = c.crust, bg = c.base })
	hl.hi("VertSplit", { fg = c.crust, bg = c.base })

	local cursorline = hl.mix(c.base, c.surface0, 0.45)
	hl.hi("CursorLine", { bg = cursorline })
	hl.hi("MatchParen", { fg = c.accent, bg = cursorline, bold = true })

	hl.hi("Search", { fg = c.text, bg = c.surface0 })
	hl.hi("IncSearch", { fg = c.crust, bg = c.base0B, bold = true })
	hl.hi("CurSearch", { fg = c.crust, bg = c.base0A, bold = true })

	hl.set({ "FloatShadow", "FloatShadowThrough", "FloatShadowBorder" }, { fg = c.surface2, bg = c.crust })
	hl.set({ "RedrawDebugComposed", "RedrawDebugClear" }, { fg = c.crust, bg = c.crust })
	hl.hi("RedrawDebugRecompose", { fg = c.base, bg = c.base })
end
