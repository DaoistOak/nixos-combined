{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    hl.define_submap("apps", "reset", function()
      hl.bind("W", hl.dsp.submap("apps-web"), { description = "Web browsers submenu" })
      hl.bind("E", hl.dsp.submap("apps-editor"), { description = "Editors submenu" })
      hl.bind("F", hl.dsp.submap("apps-file"), { description = "Files submenu" })
      hl.bind("M", hl.dsp.submap("apps-media"), { description = "Media submenu" })
      hl.bind("G", hl.dsp.submap("apps-games"), { description = "Games submenu" })
      hl.bind("A", hl.dsp.submap("apps-ai"), { description = "AI assistants submenu" })
      hl.bind("P", hl.dsp.exec_cmd("keepassxc"), { description = "KeepassXC (mode E)" })
      hl.bind("V", hl.dsp.exec_cmd(scripts .. "/submap-timeout.sh vm 2 virt-manager && hyprctl dispatch \"hl.dsp.submap('apps-vm')\""), { description = "Virtual machines (timeout: open virt-manager)" })
      hl.bind("escape", hl.dsp.submap("reset"), { description = "Exit apps mode" })
    end)
  '';
}
