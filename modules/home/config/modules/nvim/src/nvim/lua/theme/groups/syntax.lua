-- Syntax: titles, markdown headings, comments, conceal characters.
local hl = require("theme.hl")

return function(c)
	hl.hi("Title", { fg = c.accent, bold = true })
	hl.set({ "@text.title", "TSTitle", "@markup.heading" }, { link = "Title" })
	hl.hi("@markup.heading.1.markdown", { fg = c.text, bold = true })
	hl.hi("@markup.heading.2.markdown", { fg = c.accent, bold = true })
	for level = 3, 6 do
		hl.hi(("@markup.heading.%d.markdown"):format(level), { fg = c.accent })
	end

	hl.hi("Special", { fg = c.base0C })
	hl.hi("Comment", { fg = c.overlay0, bg = "NONE", italic = true })
	hl.set({ "@comment", "TSComment", "SpecialComment" }, { link = "Comment" })
	hl.hi("@comment.error", { fg = c.base08, italic = true })
	hl.hi("@comment.warning", { fg = c.base09, italic = true })
	hl.hi("@comment.todo", { fg = c.accent, italic = true })
	hl.hi("@comment.note", { fg = c.base0A, italic = true })
	hl.set({ "EndOfBuffer", "Conceal", "SpecialKey" }, { fg = c.surface2 })
end
