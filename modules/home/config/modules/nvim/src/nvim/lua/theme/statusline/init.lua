-- The lualine theme table plus the statusline groups lualine does not own.
local hl = require("theme.hl")

local M = {}

-- Paints the statusline and returns the lualine theme. Mode pill NORMAL: the
-- fill carries the mode, the label is `base` on top of it.
function M.paint(c)
	local mode_fills = {
		-- One hue per mode, straight out of the palette: the accent for normal,
		-- the named blue/mauve roles for insert/visual, base16 slots for the
		-- rest. base0C (teal) is left out on purpose, it is the default accent
		-- and would collide with normal.
		normal = c.accent,
		insert = c.blue,
		visual = c.mauve,
		replace = c.base08,
		command = c.base0A,
		terminal = c.base0B,
		inactive = c.surface0,
	}
	local theme = {}
	for mode, fill in pairs(mode_fills) do
		local inactive = mode == "inactive"
		local bg = inactive and c.surface0 or fill
		theme[mode] = {
			-- Dark label on the fill, like tmux's message-command-style: the
			-- fills are full-brightness accents now, not washes of base.
			a = { fg = inactive and c.text or c.base, bg = bg, bold = not inactive },
			-- One band per section, so a section reads as a single block: b (git
			-- branch) on surface2, everything from the filetype onwards on surface0.
			b = { fg = c.subtext0, bg = c.surface2 },
			c = { fg = c.text, bg = c.surface0 },
			x = { fg = c.subtext0, bg = c.surface0 },
			y = { fg = c.subtext0, bg = c.surface0 },
			z = { fg = c.subtext0, bg = c.surface0 },
		}
		hl.hi("StatusLineCap_" .. mode, { fg = bg, bg = inactive and c.mantle or c.surface0 })
	end
	hl.hi("StatusLine", { fg = c.subtext0, bg = c.surface0 })
	hl.hi("StatusLineNC", { fg = c.overlay0, bg = c.mantle })
	hl.hi("StatusLineCapRight", { fg = c.surface0, bg = c.base })
	return theme
end

function M.sync(theme)
	for mode, sections in pairs(theme) do
		for section, colour in pairs(sections) do
			hl.hi("lualine_" .. section .. "_" .. mode, vim.tbl_extend("force", { nocombine = true }, colour))
		end
	end
	pcall(function()
		require("lualine").refresh()
	end)
end

return M
