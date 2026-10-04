-- lualine draws the statusline with powerline glyphs out of the private use
-- area, two pairs that are independent:
--
--   * between components it defaults to U+E0B1/U+E0B3, and between sections to
--     the sharp angled U+E0B0/U+E0B2.
--
-- Only the component pair is swapped here, for the thick rounded U+E0B5/U+E0B7:
-- same half-circle shapes as the defaults, but rounded and thick instead of
-- sharp and thin.
local function glyph(code)
	return vim.fn.nr2char(code)
end

local comp_left = glyph(0xE0B5)
local comp_right = glyph(0xE0B7)

-- The section dividers stay on the thin rounded pair.
local sep_left = glyph(0xE0B4)
local sep_right = glyph(0xE0B6)

-- Line caps, using the same pair as the tmux status line (see
-- modules/home/config/modules/tmux): the line opens with U+E0B6 on the left and
-- closes with U+E0B4 on the right.
local cap_left = glyph(0xE0B6)
local cap_right = glyph(0xE0B4)

-- The caps are static highlight groups instead of components that resolve their
-- own colour on every redraw. lualine builds the whole statusline string *before*
-- drawing it, so a component calling nvim_set_hl while the string is composed
-- leaves neovide (which composites its own glyph atlas against the groups it saw
-- at the start of the frame) painting the caps in the foreground colour, over and
-- over. theme.lua derives StatusLineCapLeft/Right from the palette, next to the
-- blocks they join, and regenerates them on ThemeReload.
local function cap_component(glyph, group)
	return {
		"%#" .. group .. "#" .. glyph,
		padding = { left = 0, right = 0 },
		separator = "",
	}
end

return {
	{
		"nvim-lualine/lualine.nvim",
		opts = {
			options = {
				component_separators = { left = comp_left, right = comp_right },
				section_separators = { left = sep_left, right = sep_right },
			},
		},
		-- LazyVim builds lualine opts in a function; a second `opts.sections` table
		-- would merge arrays positionally and drop the mode component.
		config = function(_, opts)
			opts.options = opts.options or {}
			opts.options.theme = require("theme").lualine_theme() or "auto"
			opts.sections = opts.sections or {}

			for _, section in pairs(opts.sections) do
				if type(section) == "table" then
					for i = #section, 1, -1 do
						local component = section[i]
						local name = type(component) == "table" and component[1] or component
						if name == "clock" or name == "date" then
							table.remove(section, i)
						end
					end
				end
			end

			opts.sections.lualine_a = opts.sections.lualine_a or {}
			opts.sections.lualine_z = opts.sections.lualine_z or {}
			table.insert(opts.sections.lualine_a, 1, cap_component(cap_left, "StatusLineCapLeft"))
			table.insert(opts.sections.lualine_z, cap_component(cap_right, "StatusLineCapRight"))
			require("lualine").setup(opts)
		end,
	},
}
