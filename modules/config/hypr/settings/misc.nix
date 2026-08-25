{ config, lib, ... }:

{
  wayland.windowManager.hyprland = {
    settings = {
      config = {
        misc = {
          vrr = 1;
          focus_on_activate = true;
          animate_manual_resizes = true;
          animate_mouse_windowdragging = true;
          enable_swallow = true;
          disable_hyprland_logo = lib.mkForce false;
          disable_splash_rendering = false;
        };

        debug = {
          vfr = true;
        };
      };
    };
  };
}
