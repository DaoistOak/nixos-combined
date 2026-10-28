{ config, pkgs, lib, ... }:
let
  mod = "SUPER";
  scripts = "${config.xdg.configHome}/hypr/scripts";
in {
  config = {
    wayland.windowManager.hyprland.extraConfig = ''
      local mod = "${mod}"
      local scripts = "${scripts}"

      -- Shared utilities
      local superTap = { armed = false }
      local spaceTap = { count = 0 }
      local spaceTapTimer
      do
        spaceTapTimer = hl.timer(function()
          spaceTap.count = 0
          spaceTapTimer:set_enabled(false)
        end, { timeout = 600, type = "repeat" })
        spaceTapTimer:set_enabled(false)
      end

      local gamepadHoldMs = 500
      local gamepadHolds = {}

      local bind_tap_hold = function(keys, short_dsp, long_dsp, label)
        local press = { long = false }
        gamepadHolds[keys] = press
        press.timer = hl.timer(function()
          if gamepadHolds[keys] ~= press then return end
          press.long = true
          hl.dispatch(long_dsp)
        end, { timeout = gamepadHoldMs, type = "oneshot" })
      end
    '';
  };
}
