-- lualine draws the statusline with powerline glyphs out of the private use
-- area, two pairs that are independent:
--
--   * between components it defaults to U+E0B1/U+E0B3, and between sections to
--     the sharp angled U+E0B0/U+E0B2.
--
-- Only the component pair is swapped here, for the thick rounded U+E0B5/U+E0B7:
-- same half-circle shapes as the defaults, but rounded and thick instead of
-- sharp and thin.
local comp_left = "\u{E0B5}"
local comp_right = "\u{E0B7}"

-- The section dividers stay on the thin rounded pair.
local sep_left = "\u{E0B4}"
local sep_right = "\u{E0B6}"

-- Line caps, using the same pair as the tmux status line (see
-- modules/home/config/modules/tmux): the line opens with U+E0B6 on the left and
-- closes with U+E0B4 on the right.
local cap_left = "\u{E0B6}"
local cap_right = "\u{E0B4}"

-- The group lualine paints section a with: lualine_a_normal, lualine_a_insert,
-- lualine_a_visual, ... Tracking the mode suffix is what makes the left cap
-- follow the mode block. The auto theme also maps x/y/z onto c/b/a
-- (section_highlight_map in lualine/highlight.lua), so the clock in section z is
-- painted with the *same* lualine_a<suffix> colors, which is why the right cap
-- reuses this group too. Read the suffix rather than asking for a resolved
-- highlight: lualine's theme state is not populated yet while the statusline is
-- being drawn, so format_highlight returns empty at exactly that point.
-- Required lazily: lualine is a lazy-loaded plugin.
local function bar_group()
  return "lualine_a" .. require("lualine.highlight").get_mode_suffix()
end

local function bg_of(names)
  for _, name in ipairs(names) do
    local bg = vim.api.nvim_get_hl(0, { name = name, link = false }).bg
    if bg then
      return bg
    end
  end
end

-- A cap is the bar's own background drawn over the editor background, which is
-- what tmux does with #[fg=<bar bg>,bg=<terminal bg>]<glyph>. A lualine component
-- can only pick a whole highlight group, and a cap needs the *background* of the
-- bar next to it, so resolve the pair into a highlight group and select it with
-- %#. Resolving per redraw (instead of once at setup) keeps the caps correct when
-- the palette changes, e.g. on SIGUSR1 from scripts/theme, and when the mode
-- changes and lualine repaints the mode block.
local function cap(glyph, group)
  return function()
    local editor_bg = bg_of({ "Normal", "EndOfBuffer" }) or 0
    local bar_bg = bg_of({ bar_group(), "Normal" }) or editor_bg
    vim.api.nvim_set_hl(0, group, { fg = bar_bg, bg = editor_bg })
    return "%#" .. group .. "#" .. glyph
  end
end

-- Each cap needs its own highlight group: lualine builds the whole statusline
-- string before it is drawn, so a shared group would leave both glyphs in the
-- color the last cap resolved.
local function cap_component(glyph, group)
  return {
    cap(glyph, group),
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
    -- LazyVim builds its lualine opts in a function, so the caps are inserted
    -- here rather than through `sections` in opts: tbl_deep_extend merges arrays
    -- positionally, so `sections.lualine_a = { cap }` would overwrite index 1 and
    -- drop the mode component. LazyVim's lualine spec has no `config`, so this
    -- one is the only setup call.
    config = function(_, opts)
      -- Left cap inherits the mode block's color, right cap the clock's; both
      -- resolve to lualine_a<mode suffix> under the auto theme.
      table.insert(opts.sections.lualine_a, 1, cap_component(cap_left, "StatusLineCapLeft"))
      table.insert(opts.sections.lualine_z, cap_component(cap_right, "StatusLineCapRight"))
      require("lualine").setup(opts)
    end,
  },
}
