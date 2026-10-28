{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    hl.define_submap("shell", "reset", function()
      hl.bind("B", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh bluetooth 2 noctalia msg panel-toggle control-center bluetooth && hyprctl dispatch \"hl.dsp.submap('shell-bluetooth')\""), { description = "Bluetooth submenu (idle: panel)" })
      hl.bind("N", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh network 2 noctalia msg panel-toggle control-center network && hyprctl dispatch \"hl.dsp.submap('shell-network')\""), { description = "Network submenu (idle: panel)" })
      hl.bind("SHIFT + N", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center notifications"), { description = "Notifications panel" })
      hl.bind("S", hl.dsp.exec_cmd("noctalia msg panel-toggle alexander/screen-toolkit:panel"), { description = "Screen tools panel (mode S)" })
      hl.bind("SHIFT + S", hl.dsp.exec_cmd("flameshot gui"), { description = "Flameshot screenshot (mode S)" })
      hl.bind("Q", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"), { description = "Control center (mode S)" })
      hl.bind("M", hl.dsp.exec_cmd("noctalia msg media toggle"), { description = "Media menu (mode S)" })
      hl.bind("W", hl.dsp.exec_cmd("noctalia msg panel-toggle wallpaper"), { description = "Wallpaper picker (mode S)" })
      hl.bind("R", hl.dsp.exec_cmd(scripts .. "/noctalia-restart.sh"), { description = "Restart noctalia (mode S)" })
      hl.bind("P", hl.dsp.exec_cmd("~/bin/colorpicker"), { description = "Color picker (mode S)" })
      hl.bind("K", hl.dsp.exec_cmd("keyviz"), { description = "Keyviz keypress visualizer (mode S)" })
      hl.bind("C", hl.dsp.exec_cmd("noctalia msg panel-toggle yuuto/calculator:panel"), { description = "Calculator panel (mode S)" })
      hl.bind("G", hl.dsp.exec_cmd(scripts .. "/performance-mode.sh"), { description = "Toggle performance mode (gaps/corners/transparency/border rotate)" })
      hl.bind("SHIFT + V", hl.dsp.exec_cmd(scripts .. "/session-restore.sh"), { description = "Restore session (mode S)" })
      hl.bind("D", hl.dsp.submap("shell-widgets"), { description = "Widget toggles submenu" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit shell mode" })
    end)
  '';
}
