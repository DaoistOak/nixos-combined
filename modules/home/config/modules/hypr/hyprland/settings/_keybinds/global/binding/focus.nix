{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    -- 5. FOCUS (SUPER)
    hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }), { description = "Focus left" })
    hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }), { description = "Focus right" })
    hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }), { description = "Focus up" })
    hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }), { description = "Focus down" })
    hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }), { description = "Focus left (vim)" })
    hl.bind(mod .. " + J", hl.dsp.focus({ direction = "d" }), { description = "Focus down (vim)" })
    hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }), { description = "Focus up (vim)" })
    hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }), { description = "Focus right (vim)" })
  '';
}
