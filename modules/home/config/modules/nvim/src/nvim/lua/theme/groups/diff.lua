-- Diffs, for the built-in diff and diffview.nvim.
local hl = require("theme.hl")

return function(c)
	hl.set({ "DiffAdd", "DiffviewDiffAdd" }, { fg = c.base0B })
	hl.set({ "DiffChange", "DiffviewDiffChange" }, { fg = c.base0D })
	hl.set({ "DiffDelete", "DiffviewDiffDelete", "DiffviewDiffAddAsDelete" }, { fg = c.base08 })
	hl.hi("DiffText", { fg = c.text, bg = c.surface0 })
	hl.hi("DiffTextAdd", { fg = c.base0B, bg = c.surface0 })
	hl.hi("DiffTextChange", { fg = c.base0D, bg = c.surface0 })
	hl.hi("DiffTextDelete", { fg = c.base08, bg = c.surface0 })
end
