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

-- The left cap opens the mode pill: it is literal statusline text, because the
-- round end needs two colours in one cell (the pill fill and the bar behind it)
-- and a component's own group can only hold one pair. It switches to the
-- pre-built StatusLineCap_<mode> group from theme/statusline, which is repainted
-- with the palette, so do not call nvim_set_hl while the statusline string is
-- composed: neovide caches groups for the frame.
local function cap(group, code)
	return "%#" .. group .. "#" .. code
end

-- The mode pill is one component: the cap opens it, the label follows. Both
-- groups are keyed by theme.lualine_mode(), so the cap can never lag a frame
-- behind the fill it has to match.
local function mode_pill()
	local theme = require("theme")
	local mode = theme.lualine_mode()
	local ok, util = pcall(require, "lualine.utils.mode")
	local label = ok and util.get_mode() or mode:upper()
	return cap("StatusLineCap_" .. mode, cap_left) .. "%#lualine_a_" .. mode .. "# " .. label .. " "
end

local pill = {
	mode_pill,
	padding = { left = 0, right = 0 },
	separator = "",
}

-- The right cap is the last cell of the line, and the right-aligned sections
-- (y, z) get a section divider prepended (utils/section.lua). With z holding
-- nothing but the cap that divider would land on the cap and paint a second,
-- unpaired end, so it is switched off here.
--
-- The glyph is the component's content and its colour is a group name: lualine
-- links the component group to StatusLineCapRight (highlight.lua,
-- create_component_highlight_group), so the cell shows the bar colour on the
-- base background and follows the palette on its own. That only holds because
-- nothing clears lualine's groups underneath it: setup_theme() opens with
-- clear_highlights(), which wipes every group lualine has loaded, and it runs
-- from setup() on every ColorScheme. sync_lualine() therefore repaints just the
-- a-z section groups instead of going through create_highlight_groups(); see
-- theme/statusline/init.lua.
local right_cap = {
	function()
		return cap_right
	end,
	color = "StatusLineCapRight",
	padding = { left = 0, right = 0 },
	separator = "",
	ls_separator = "",
}

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

			-- LazyVim's last section is a single anonymous function that renders
			-- the clock (LazyVim/lua/lazyvim/plugins/ui.lua), so it carries no
			-- name to match the way "clock" would: drop the functions instead.
			local z = opts.sections.lualine_z or {}
			for i = #z, 1, -1 do
				if type(z[i]) == "function" then
					table.remove(z, i)
				end
			end
			z[#z + 1] = right_cap
			opts.sections.lualine_z = z

			-- Section a is the pill alone, so the cap and the label stay one
			-- element instead of two components sharing a boundary.
			opts.sections.lualine_a = { pill }

			require("lualine").setup(opts)
		end,
	},
}
