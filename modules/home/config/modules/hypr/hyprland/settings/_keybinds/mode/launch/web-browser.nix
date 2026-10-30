{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    hl.define_submap("apps-web", "reset", function()
      hl.bind("RETURN", hl.dsp.exec_cmd("zen"), { description = "Zen browser" })
      hl.bind("B", hl.dsp.exec_cmd("brave"), { description = "Brave browser" })
      hl.bind("Z", hl.dsp.exec_cmd("zen"), { description = "Zen browser" })
      hl.bind("F", hl.dsp.exec_cmd("firefox"), { description = "Firefox" })
      hl.bind("SHIFT + F", hl.dsp.exec_cmd("firefox --private-window"), { description = "Firefox private window" })
      hl.bind("Q", hl.dsp.exec_cmd("qutebrowser"), { description = "Qutebrowser" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit web mode" })
    end)
  '';
}
