-- Small colour helpers shared by the palette loader and the painters.
--
-- Everything in this theme is derived from the 32 hex values the theme switcher
-- writes, so the only maths that ever happens here is "mix two colours", "is
-- this colour light enough to need dark text on top of it" and "lift a colour
-- toward white" (Neovide compensation, see theme/lualine.lua).

local M = {}

--- Normalise `#rgb`, `#rrggbb` or `rrggbb` to `#rrggbb`, or nil when unparseable.
function M.hex(value)
  if type(value) ~= "string" then
    return nil
  end
  local digits = value:gsub("^#", "")
  if digits:len() == 3 then
    digits = digits:gsub("(%x)", "%1%1")
  end
  if digits:len() ~= 6 or digits:match("%X") then
    return nil
  end
  return "#" .. digits:lower()
end

local function channels(hex)
  local n = tonumber(hex:sub(2), 16)
  return bit.rshift(n, 16), bit.band(bit.rshift(n, 8), 0xFF), bit.band(n, 0xFF)
end

--- Relative luminance (WCAG), 0 (black) .. 1 (white).
function M.luminance(hex)
  local r, g, b = channels(hex)
  local lin = {}
  for i, channel in ipairs({ r, g, b }) do
    local srgb = channel / 255
    lin[i] = srgb <= 0.04045 and srgb / 12.92 or ((srgb + 0.055) / 1.055) ^ 2.4
  end
  return 0.2126 * lin[1] + 0.7152 * lin[2] + 0.0722 * lin[3]
end

--- Mix `amount` of `fg` into `bg`; 0 keeps `bg`, 1 returns `fg`.
function M.blend(fg, bg, amount)
  local fr, fg_, fb = channels(fg)
  local br, bg_, bb = channels(bg)
  local mix = function(a, b)
    return math.floor(math.max(0, math.min(255, a * amount + b * (1 - amount))) + 0.5)
  end
  return ("#%02x%02x%02x"):format(mix(fr, br), mix(fg_, bg_), mix(fb, bb))
end

--- Screen-mix `hex` toward white: every channel travels `amount` of its
--- remaining distance to #ffffff. Hue ratios stay intact (a lifted teal is
--- still teal), only the result reads brighter — 0 keeps `hex`, 1 is white.
function M.lift(hex, amount)
  local r, g, b = channels(hex)
  local up = function(a)
    return math.floor(255 - (255 - a) * (1 - amount) + 0.5)
  end
  return ("#%02x%02x%02x"):format(up(r), up(g), up(b))
end

--- True when a colour needs dark (not palette text) foregrounds on top of it.
function M.needs_dark_text(hex)
  return M.luminance(hex) > 0.32
end

--- Foreground that stays readable on `bg`, preferring `dark` then `light`.
function M.on(bg, dark, light)
  return M.needs_dark_text(bg) and dark or light
end

return M
