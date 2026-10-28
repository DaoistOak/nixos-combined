{ config, pkgs, ... }:
{
  wayland.windowManager.hyprland.extraConfig = ''
    hl.bind(mod .. " + SUPER_L", function()
      superTap.armed = true
    end, { description = "Launcher (SUPER tap)" })
    hl.on("input.keyboard.key", function(keycode, _, state)
      if state == 1 and keycode ~= 133 and keycode ~= 134 and superTap.armed then
        superTap.armed = false
      end
    end)
    hl.bind(mod .. " + SUPER_L", function()
      if superTap.armed then
        hl.exec_cmd(scripts .. "/super-tap-launcher.sh")
      end
      superTap.armed = false
    end, { release = true, description = "Launcher (SUPER tap)" })
  '';
}
