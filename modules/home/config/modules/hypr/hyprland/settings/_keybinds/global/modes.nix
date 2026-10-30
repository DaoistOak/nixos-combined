{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    -- 3. MODES (SUPER)
    hl.bind(mod .. " + T", hl.dsp.submap("terminal-apps"), { description = "Enter terminal-apps mode" })
    hl.bind(mod .. " + S", hl.dsp.submap("shell"), { description = "Enter shell mode" })
    hl.bind(mod .. " + E", hl.dsp.submap("apps"), { description = "Enter apps mode" })
    hl.bind(mod .. " + M", hl.dsp.submap("messaging"), { description = "Enter messaging mode" })
    hl.bind(mod .. " + W", hl.dsp.submap("windows"), { description = "Enter windows mode" })
  '';
}
