-- Pickers: telescope.nvim and the snacks picker.
local hl = require("theme.hl")

return function(c)
	hl.hi("TelescopeNormal", { fg = c.text, bg = c.surface0 })
	hl.hi("TelescopeBorder", { fg = c.surface2, bg = c.surface0 })
	hl.hi("TelescopePromptNormal", { fg = c.text, bg = c.surface0 })
	hl.hi("TelescopePromptBorder", { fg = c.surface2, bg = c.surface0 })
	hl.hi("TelescopePromptPrefix", { fg = c.accent, bg = c.surface0 })
	hl.hi("TelescopePromptCounter", { fg = c.overlay0, bg = c.surface0 })
	hl.hi("TelescopePromptTitle", { fg = c.base, bg = c.accent, bold = true })
	hl.hi("TelescopeResultsTitle", { fg = c.base, bg = c.accent, bold = true })
	hl.hi("TelescopePreviewTitle", { fg = c.base, bg = c.base0A, bold = true })
	hl.hi("TelescopeSelection", { fg = c.text, bg = c.surface1 })
	hl.hi("TelescopeSelectionCaret", { fg = c.accent, bg = c.surface1 })
	hl.hi("TelescopeMatching", { fg = c.accent, bold = true })
	hl.hi("TelescopePreviewLine", { bg = c.surface1 })

	hl.hi("SnacksPickerNormal", { fg = c.text, bg = c.surface0 })
	hl.hi("SnacksPickerList", { fg = c.text, bg = c.surface0 })
	hl.hi("SnacksPickerListCursorLine", { fg = c.text, bg = c.surface1 })
	hl.set({ "SnacksPickerDir", "SnacksPickerDirIcon" }, { fg = c.accent, bg = c.surface0 })
	hl.hi("SnacksPickerFileIcon", { fg = c.overlay1, bg = c.surface0 })
	hl.set({ "SnacksPickerSpecial", "SnacksPickerPrompt", "SnacksPickerTotals" }, { fg = c.accent, bg = c.surface0 })
	hl.set({ "SnacksPickerPathHidden", "SnacksPickerPathIgnored" }, { fg = c.overlay0, bg = c.surface0 })
	hl.hi("SnacksPickerBorder", { fg = c.surface2, bg = c.surface0 })
	hl.hi("SnacksPickerTitle", { fg = c.base, bg = c.accent, bold = true })
	hl.set({ "SnacksPickerSelected", "SnacksPickerListSelected" }, { fg = c.text, bg = c.surface1 })
	hl.hi("SnacksPickerMatch", { fg = c.accent, bold = true })
	hl.set({ "SnacksIndent", "SnacksIndentChunk", "SnacksIndentScope", "SnacksIndentUnderline" }, {
		fg = c.surface2,
		bg = c.base,
	})
end
