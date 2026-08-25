{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "noctalia msg session lock";
        before_sleep_cmd = "loginctl lock-session;";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };

      listener = [
        {
          timeout = 150; # 2.5 minutes
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
          condition_cmd = "${config.home.homeDirectory}/.config/hypr/scripts/media-idle-check.sh";
          condition_retry = 30;
        }
        {
          timeout = 300; # 5 minutes
          on-timeout = "loginctl lock-session";
          condition_cmd = "${config.home.homeDirectory}/.config/hypr/scripts/media-idle-check.sh";
          condition_retry = 30;
        }
        {
          timeout = 330; # 5.5 minutes
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
          condition_cmd = "${config.home.homeDirectory}/.config/hypr/scripts/media-idle-check.sh";
          condition_retry = 30;
        }
        {
          timeout = 1800; # 30 minutes
          on-timeout = "systemctl hibernate";
          condition_cmd = "${config.home.homeDirectory}/.config/hypr/scripts/media-idle-check.sh";
          condition_retry = 30;
        }
      ];
    };
  };
}
