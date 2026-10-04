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
    -- LazyVim builds its lualine opts in a function, so the theme and the caps
    -- are applied here rather than through `opts`: tbl_deep_extend merges arrays
    -- positionally, so `sections.lualine_a = { cap }` would overwrite index 1 and
    -- drop the mode component. LazyVim's lualine spec has no `config`, so this one
    -- is the only setup call.
    config = function(_, opts)
      -- The palette owns the block colours (see theme.lua). Hand lualine that
      -- table instead of leaving it on "auto": automatic mode copies the colours
      -- of the block after each component, which is what made the bar a flat blur
      -- of the mode colour, and it cannot express the caps above at all.
      opts.options.theme = require("theme").lualine_theme() or "auto"
      -- LazyVim lays the sections out as
      --   a mode | b branch | c root/diagnostics/path | x profiler | y progress/location | z clock
      -- with a leftmost and z rightmost, so a cap goes in front of a and after z:
      -- a glyph in the block colour on the bare bar, opening the mode block out
      -- of the strip and closing the clock block into it.
      table.insert(opts.sections.lualine_a, 1, cap_component(cap_left, "StatusLineCapLeft"))
      table.insert(opts.sections.lualine_z, cap_component(cap_right, "StatusLineCapRight"))
      require("lualine").setup(opts)
    end,
  },
}