-- vim.fn.mode() -> the lualine theme key. The pill and the cap look their groups
-- up by this, so they cannot lag a frame behind the fill they have to match.
local M = {}

local mode_names = {
	n = "normal",
	no = "normal",
	nov = "normal",
	i = "insert",
	ic = "insert",
	ix = "insert",
	v = "visual",
	V = "visual",
	["\22"] = "visual",
	s = "visual",
	S = "visual",
	["\19"] = "visual",
	R = "replace",
	Rv = "replace",
	c = "command",
	cv = "command",
	ce = "command",
	t = "terminal",
}

function M.current()
	return mode_names[vim.fn.mode()] or "normal"
end

return M
