{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    hl.bind(mod .. " + SHIFT + escape", hl.dsp.submap("passthru"), { description = "Enter passthrough mode" })
    hl.define_submap("passthru", "reset", function()
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit passthrough mode" })
    end)
  '';
}
