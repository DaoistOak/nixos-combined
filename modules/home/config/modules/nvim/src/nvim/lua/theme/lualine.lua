-- lualine integration.
--
-- lualine bakes its highlight groups from a theme table at setup time and never
-- looks at the palette again, so a palette change has to hand it a fresh table
-- and let it rebuild its groups (see `sync`). `lua/plugins/lualine.lua` passes
-- `theme()` straight through as its `theme` option, which means this table is
-- the single source of truth for both the first render and every reload.

local M = {}

local color = require("theme.color")

-- Neovide renders cell backgrounds visibly darker than ghostty/tmux do for the
-- same highlight (neovide/neovide#2050: colours look darker in Neovide than in
-- a terminal; there is no config knob for cell backgrounds, `neovide_text_gamma`
-- only affects glyphs). Lift the mode fills while inside Neovide so the pills
-- read as vivid as they do in a terminal; every other frontend keeps the raw
-- palette colours. Tune the share here if Neovide ever changes its pipeline.
local NEOVIDE_FILL_LIFT = 0.18

local function vivid(hex)
  if not vim.g.neovide then
    return hex
  end
  return color.lift(hex, NEOVIDE_FILL_LIFT)
end

--- Mode fills. Normal is the palette accent, everything else picks a distinct
--- slot so the mode viewer stays readable at a glance.
local function mode_fills(c)
  return {
    normal = vivid(c.accent),
    insert = vivid(c.blue),
    visual = vivid(c.mauve),
    replace = vivid(c.base08),
    command = vivid(c.base0A),
    terminal = vivid(c.base0B),
    inactive = c.surface0,
  }
end

--- Build the lualine theme table for a palette.
---
--- Colours are assigned so that the statusline reads as a symmetric frame:
--- section a (mode pill) and section z (clock) share the mode's accent fill,
--- section b (branch) sits on the darker surface band, and c/x/y form a
--- graduated middle on surface0. This gives a visible Powerline step at every
--- transition instead of the old flat stretch across c–z.
function M.theme(c)
  local fills = mode_fills(c)
  local t = {}

  for mode, fill in pairs(fills) do
    t[mode] = {
      -- Mode pill: accent fill, dark text on top, bold.
      a = { fg = c.contrast.on(fill), bg = fill, gui = "bold" },
      -- Branch: dim text on the darker surface band.
      b = { fg = c.blue, bg = c.surface2 },
      -- Main content area - all components base on surface0
      c = { fg = c.fg.text, bg = c.surface0, gui = "bold" },
      -- Secondary info moved to y
      x = { fg = c.subtext0, bg = c.surface0 },
      -- x components moved to y with surface1 bg
      y = { fg = c.subtext0, bg = c.surface1 },
      -- y components moved to z with surface2 bg
      z = { fg = c.accent, bg = c.surface2 },
    }
  end

  -- Make section c stand out more in normal mode
  t.normal.c = { fg = c.fg.text, bg = c.surface0, gui = "bold" }
  t.normal.y = { fg = c.subtext0, bg = c.surface1 }
  t.normal.z = { fg = c.accent, bg = c.surface2 }

  -- Explicit inactive state
  t.inactive = {
    a = { fg = c.overlay1, bg = c.surface0 },
    b = { fg = c.blue, bg = c.surface0 },
    c = { fg = c.overlay1, bg = c.surface0 },
    x = { fg = c.overlay1, bg = c.surface0 },
    y = { fg = c.overlay1, bg = c.surface1 },
    z = { fg = c.accent, bg = c.surface2 },
  }

  return t
end

--- Push the current palette into a running lualine. No-op before lualine is
--- loaded, which is the case when the colourscheme loads at startup.
function M.sync()
  if not package.loaded["lualine"] then
    return
  end
  local highlight = require("lualine_require").require("lualine.highlight")
  highlight.create_highlight_groups(M.theme(require("theme.palette").load()))
  require("lualine").refresh()
end

return M
