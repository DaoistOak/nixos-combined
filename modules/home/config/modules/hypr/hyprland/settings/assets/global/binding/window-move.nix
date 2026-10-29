
    -- 6. WINDOW MOVE (SUPER)
    hl.bind(mod .. " + SHIFT + left", hl.dsp.layout("swapcol l"), { description = "Move window left (swap column)" })
    hl.bind(mod .. " + SHIFT + right", hl.dsp.layout("swapcol r"), { description = "Move window right (swap column)" })
    hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }), { description = "Move window up" })
    hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }), { description = "Move window down" })
    hl.bind(mod .. " + SHIFT + ALT + left", hl.dsp.window.move({ direction = "l" }), { description = "Move window left (keep column)" })
    hl.bind(mod .. " + SHIFT + ALT + right", hl.dsp.window.move({ direction = "r" }), { description = "Move window right (keep column)" })
    hl.bind(mod .. " + SHIFT + H", hl.dsp.layout("swapcol l"), { description = "Move window left (swap column, vim)" })
    hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }), { description = "Move window down (vim)" })
    hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }), { description = "Move window up (vim)" })
    hl.bind(mod .. " + SHIFT + L", hl.dsp.layout("swapcol r"), { description = "Move window right (swap column, vim)" })
  