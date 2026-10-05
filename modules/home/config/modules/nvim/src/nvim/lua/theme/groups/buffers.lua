-- bufferline.nvim.
--
-- bufferline resolves the buffer *name* through hl_group("buffer", "background")
-- (lua/bufferline/highlights.lua), so a plain inactive buffer is painted with
-- BufferLineBackground, not BufferLineBuffer: only "visible" (shown in another
-- window) and "selected" get their own groups. Painting it mantle-on-mantle is
-- what hid the inactive titles, so only the fill stays invisible.
local hl = require("theme.hl")
local palette = require("theme.palette")

return function(c)
	hl.hi("BufferLineBackground", { fg = c.subtext0, bg = c.mantle })
	hl.hi("BufferLineFill", { fg = c.mantle, bg = c.mantle })
	-- Inactive titles need to stay readable: overlay0 on mantle is too close to
	-- the bar background to read, let alone to look like the crust behind it.
	hl.set({
		"BufferLineBuffer",
		"BufferLineBufferVisible",
		"BufferLineTab",
		"BufferLineOffsetSeparator",
	}, { fg = c.subtext0, bg = c.mantle })
	hl.set({ "BufferLineBufferSelected", "BufferLineTabSelected" }, { fg = c.text, bg = c.base, bold = true })
	hl.set({ "BufferLineSeparator", "BufferLineTabSeparator" }, { fg = c.mantle, bg = c.mantle })
	hl.set({ "BufferLineSeparatorSelected", "BufferLineTabSeparatorSelected" }, { fg = c.base, bg = c.base })
	hl.set({ "BufferLineIndicatorVisible", "BufferLineIndicatorSelected" }, { fg = c.accent, bg = c.base })
	hl.set({
		"BufferLineCloseButton",
		"BufferLineCloseButtonVisible",
		"BufferLineTabClose",
	}, { fg = c.overlay0, bg = c.mantle })
	hl.set({ "BufferLineCloseButtonSelected", "BufferLineTabCloseSelected" }, { fg = c.text, bg = c.base })
	hl.set({ "BufferLineNumbers", "BufferLineNumbersVisible" }, { fg = c.overlay0, bg = c.mantle })
	hl.hi("BufferLineNumbersSelected", { fg = c.subtext0, bg = c.base })
	hl.set({ "BufferLineModified", "BufferLineModifiedVisible" }, { fg = c.accent, bg = c.mantle })
	hl.hi("BufferLineModifiedSelected", { fg = c.accent, bg = c.base, bold = true })
	hl.set({ "BufferLineDuplicate", "BufferLineDuplicateVisible" }, { fg = c.subtext0, bg = c.mantle, italic = true })
	hl.hi("BufferLineDuplicateSelected", { fg = c.subtext1, bg = c.base, italic = true })
	hl.hi("BufferLineGroupLabel", { fg = c.accent, bg = c.mantle, bold = true })
	hl.hi("BufferLineGroupSeparator", { fg = c.surface1, bg = c.mantle })
	hl.set({ "BufferLineTruncMarker", "BufferLineDiagnostic", "BufferLineDiagnosticVisible" }, {
		fg = c.overlay0,
		bg = c.mantle,
	})
	hl.hi("BufferLineDiagnosticSelected", { fg = c.subtext0, bg = c.base })
	hl.set({ "BufferLinePick", "BufferLinePickVisible" }, { fg = c.text, bg = c.surface0 })
	hl.hi("BufferLinePickSelected", { fg = c.text, bg = c.surface1 })
	for _, s in ipairs(palette.severity(c)) do
		local name, colour = "BufferLine" .. s.bufferline, s.colour
		hl.set({ name, name .. "Visible" }, { fg = colour, bg = c.mantle })
		hl.hi(name .. "Diagnostic", { fg = colour, bg = c.mantle })
		hl.hi(name .. "Selected", { fg = colour, bg = c.base })
		hl.hi(name .. "DiagnosticSelected", { fg = colour, bg = c.base })
	end
end
