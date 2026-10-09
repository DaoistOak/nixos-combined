-- Loads the palette that the Nix side of the config keeps up to date.
--
-- `scripts/theme` regenerates ~/.config/theme-switcher/nvim-base16.lua and then
-- signals the running Neovim, so this module never generates colours itself: it
-- only reads the file, normalises it and expands the named roles into the small
-- ramps the painters use (`c.fg.dim`, `c.bg.raised`, ...). That keeps every
-- painter agnostic about base16 slot numbering and means a palette file written
-- by a newer theme definition needs no changes here.

local color = require("theme.color")

local M = {}

M.path = vim.fn.expand("~/.config/theme-switcher/nvim-base16.lua")

--- Roles a palette file must carry. Anything missing falls back to the base16
--- slots so an older generated file still loads.
local FALLBACKS = {
  crust = "base00",
  mantle = "base01",
  base = "base00",
  surface0 = "base01",
  surface1 = "base02",
  surface2 = "base03",
  overlay0 = "base03",
  overlay1 = "base04",
  overlay2 = "base05",
  subtext0 = "base04",
  subtext1 = "base05",
  text = "base05",
  accent = "base0D",
  blue = "base0D",
  mauve = "base0E",
}

local cache

local function read_file()
  local chunk, err = loadfile(M.path)
  if not chunk then
    return nil, ("theme: cannot read palette %s: %s"):format(M.path, err)
  end
  local ok, raw = pcall(chunk)
  if not ok or type(raw) ~= "table" then
    return nil, ("theme: palette %s did not return a table"):format(M.path)
  end
  return raw
end

--- Expand a raw palette table into the shape the painters expect.
function M.expand(raw)
  local c = {}
  for key, value in pairs(raw) do
    local hex = color.hex(value)
    -- base00-base0F (note %x covers upper case, so base0A..base0F match) plus
    -- the named roles (crust, surface0, overlay1, subtext0, accent, ...).
    if hex and (key:match("^base0%x$") or key:match("^[a-z]+%d?$")) then
      c[key] = hex
    end
  end

  for role, slot in pairs(FALLBACKS) do
    if not c[role] then
      c[role] = c[slot]
    end
  end
  for _, slot in ipairs({ "base00", "base01", "base02", "base03", "base04", "base05" }) do
    if not c[slot] then
      return nil, ("theme: palette %s is missing %s"):format(M.path, slot)
    end
  end

  -- Foreground ramp: text is the brightest, everything below it steps down.
  c.fg = {
    text = c.text,
    base = c.subtext1,
    dim = c.subtext0,
    faint = c.overlay1,
    muted = c.overlay0,
  }
  -- Background ramp: base is the editor surface, raised/sunken/overlay are the
  -- floats and gutters, `line` is the cursor line / selection wash.
  c.bg = {
    base = c.base,
    raised = c.surface0,
    line = color.blend(c.surface0, c.base, 0.28),
    sunken = c.mantle,
    shadow = c.crust,
    overlay = c.crust,
  }
  c.contrast = {
    --- Foreground that stays readable on `fg` (a mode fill, an accent, ...).
    on = function(fg)
      return color.on(fg, c.base, c.text)
    end,
  }

  return c
end

--- Read, expand and memoise the palette. A failed read keeps the last good one
--- so a transient write from `scripts/theme` cannot blank the colours.
function M.load()
  if cache then
    return cache
  end
  local raw, err = read_file()
  if not raw then
    if cache then
      return cache
    end
    error(err, 0)
  end
  local c, expand_err = M.expand(raw)
  if not c then
    if cache then
      return cache
    end
    error(expand_err, 0)
  end
  cache = c
  return c
end

--- Forget the memoised palette (used by tests and `:ThemeReload!`).
function M.reset()
  cache = nil
end

return M
