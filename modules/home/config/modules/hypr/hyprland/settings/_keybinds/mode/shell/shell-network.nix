{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    hl.define_submap("shell-network", "reset", function()
      hl.bind("o", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel network && " .. scripts .. "/launch-network.sh open"), { description = "Open network panel" })
      hl.bind("c", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel network && " .. scripts .. "/launch-network.sh close"), { description = "Close network panel" })
      hl.bind("escape", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel network && hyprctl dispatch \"hl.dsp.submap('reset')\""), { description = "Exit network mode" })
    end)
  '';
}
