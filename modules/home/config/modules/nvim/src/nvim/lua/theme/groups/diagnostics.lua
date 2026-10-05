-- LSP diagnostics and the diff signs they share.
local hl = require("theme.hl")
local palette = require("theme.palette")

return function(c)
	for _, s in ipairs(palette.severity(c)) do
		local name, colour = s.lsp, s.colour
		hl.set({ "Diagnostic" .. name, "DiagnosticSign" .. name }, { fg = colour })
		hl.set({ "DiagnosticVirtualText" .. name, "DiagnosticFloating" .. name }, { fg = colour })
		hl.set({ "DiagnosticVirtualLines" .. name, "DiagnosticSign" .. name .. "HL" }, { fg = colour })
		hl.hi("DiagnosticUnderline" .. name, { sp = colour, undercurl = true })
	end
	hl.set({ "DiagnosticOk", "DiagnosticUnnecessary" }, { fg = c.base0B })
	hl.set({ "DiagnosticChanged", "Changed" }, { fg = c.base0D })
	hl.set({ "DiagnosticDeprecated", "Removed" }, { fg = c.base08 })
	hl.hi("Added", { fg = c.base0B })
	hl.hi("DiagnosticUnderlineOk", { sp = c.base0B, undercurl = true })
	hl.hi("DiagnosticUnderlineDeprecated", { sp = c.base08, undercurl = true })
end
