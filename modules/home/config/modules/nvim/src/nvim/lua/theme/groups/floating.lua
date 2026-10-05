-- Surfaces that float over the editor: floats, completion, cmdline, terminals,
-- which-key.
local hl = require("theme.hl")

return function(c)
	hl.hi("NormalFloat", { fg = c.text, bg = c.surface0 })
	hl.hi("FloatBorder", { fg = c.surface2, bg = c.surface0 })
	hl.hi("FloatTitle", { fg = c.base, bg = c.accent, bold = true })
	hl.hi("FloatFooter", { fg = c.subtext0, bg = c.surface0 })

	hl.hi("Pmenu", { fg = c.text, bg = c.surface0 })
	hl.hi("PmenuSel", { fg = c.text, bg = c.surface1 })
	hl.hi("PmenuThumb", { bg = c.surface1 })
	hl.hi("PmenuMatch", { fg = c.accent, bg = c.surface0, bold = true })
	hl.hi("PmenuMatchSel", { fg = c.accent, bg = c.surface1, bold = true })
	hl.hi("WildMenu", { fg = c.text, bg = c.surface0 })

	hl.set({ "NoiceCmdline", "NoiceCmdlinePopup" }, { fg = c.text, bg = c.surface0 })
	hl.set({ "NoiceCmdlinePopupBorder", "NoiceCmdlinePopupTitle" }, { fg = c.accent, bg = c.surface0, bold = true })
	hl.set({ "NoiceCmdlineIcon", "NoiceCmdlineIconSearch", "NoiceCmdlinePrompt" }, { fg = c.accent, bg = c.surface0 })
	hl.hi("NoiceCmdlinePopupBorderSearch", { fg = c.accent, bg = c.surface0 })
	hl.set({ "NoiceConfirm", "NoiceConfirmBorder" }, { fg = c.text, bg = c.surface0 })
	hl.hi("NoicePopupmenu", { fg = c.text, bg = c.surface0 })
	hl.hi("NoicePopupmenuSelected", { fg = c.text, bg = c.surface1 })
	hl.hi("NoicePopupmenuMatch", { fg = c.accent, bg = c.surface0, bold = true })

	hl.set({ "TermNormal", "TermNormalNC" }, { fg = c.text, bg = c.surface0 })
	hl.set({ "TermCursor", "TermCursorNC" }, { fg = c.crust, bg = c.accent })
	hl.set({ "SnacksTerminalNormal", "SnacksTerminalNormalNC" }, { fg = c.text, bg = c.surface0 })
	hl.hi("SnacksTerminalCursor", { fg = c.crust, bg = c.accent })

	hl.set({ "WhichKey", "WhichKeyGroup", "WhichKeyDesc" }, { fg = c.overlay0, bg = c.surface0 })
	hl.set({ "WhichKeySeparator", "WhichKeyFloat", "WhichKeyNormal" }, { fg = c.surface1, bg = c.surface0 })
	hl.set({ "WhichKeyValue", "WhichKeyBorder" }, { fg = c.text, bg = c.surface0 })
	hl.set({ "WhichKeyIcon", "WhichKeyIconAzure" }, { fg = c.accent, bg = c.surface0 })
end
