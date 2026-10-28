{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    hl.define_submap("shell-bluetooth", "reset", function()
      hl.bind("o", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel bluetooth && " .. scripts .. "/launch-bluetooth.sh open"), { description = "Open bluetooth panel" })
      hl.bind("c", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel bluetooth && " .. scripts .. "/launch-bluetooth.sh close"), { description = "Close bluetooth panel" })
      hl.bind("a", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel bluetooth && " .. scripts .. "/launch-bluetooth.sh auto"), { description = "Toggle bluetooth auto" })
      hl.bind("escape", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel bluetooth && hyprctl dispatch \"hl.dsp.submap('reset')\""), { description = "Exit bluetooth mode" })
    end)
  '';
}
