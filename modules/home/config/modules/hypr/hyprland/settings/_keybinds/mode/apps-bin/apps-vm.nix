{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    hl.define_submap("apps-vm", "reset", function()
      hl.bind("W", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel vm && virt-manager --show-domain-editor Windows"), { description = "Open Windows VM (no launch)" })
      hl.bind("escape", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh cancel vm && hyprctl dispatch \"hl.dsp.submap('reset')\""), { description = "Exit VM mode" })
    end)
  '';
}
