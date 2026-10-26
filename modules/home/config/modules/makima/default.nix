{
  config,
  lib,
  pkgs,
  ...
}:

let
  makima = pkgs.makima;

  enable = true;

  # makima matches a config file against the device name reported by evdev
  # EXACTLY — `associated_device_name == device.name()` in src/udev_monitor.rs,
  # with no trimming. This Logitech gamepad reports " USB Gamepad          "
  # (leading space + trailing padding). Naming the file "USB Gamepad.toml" makes
  # makima print "No matching devices found" and exit.
  deviceName = " USB Gamepad          ";

  # Desktop control mode — the default layout, used for every window that has
  # no app-specific config. makima reads [settings] ONLY from this main file.
  desktopConfig = ''
    # Desktop control mode (default layout for every window)
    #
    # This is a PantherLord PS2-to-USB adapter (0810:0001). Its real evdev names:
    #   288 BTN_TRIGGER  = Triangle (North)
    #   289 BTN_THUMB    = Circle   (East)
    #   290 BTN_THUMB2   = Cross    (South)
    #   291 BTN_TOP      = Square   (West)
    #   292 BTN_TOP2     = L2
    #   293 BTN_PINKIE   = R2
    #   294 BTN_BASE     = L1
    #   295 BTN_BASE2    = R1
    [remap]
    # South (cross) -> accent + left click
    BTN_THUMB2 = ["KEY_LEFTSHIFT", "BTN_LEFT"]
    # East (circle) -> decline / close
    BTN_THUMB = ["KEY_ESC"]
    # L1 / R1 -> previous / next tab in the focused app
    BTN_BASE  = ["KEY_LEFTCTRL", "KEY_LEFTSHIFT", "KEY_TAB"]
    BTN_BASE2 = ["KEY_LEFTCTRL", "KEY_TAB"]
    # L2 / R2 -> F13 / F14; Hyprland turns tap into focus left/right and

    # L2 / R2 -> focus left / right in the Hyprland layout
    BTN_TOP2   = ["KEY_LEFTMETA", "KEY_LEFT"]
    BTN_PINKIE = ["KEY_LEFTMETA", "KEY_RIGHT"]
    [movements]
    # North (triangle) / west (square) -> scroll down / up
    BTN_TRIGGER = "SCROLL_DOWN"
    BTN_TOP     = "SCROLL_UP"

    [settings]
    LSTICK = "cursor"           # left stick moves the cursor
    LSTICK_SENSITIVITY = "12"   # higher = slower; was 6
    LSTICK_DEADZONE = "5"
    RSTICK = "disabled"
    RSTICK_SENSITIVITY = "0"
    RSTICK_DEADZONE = "64"
    SCROLL_SPEED = "12"         # emits REL_WHEEL_HI_RES (v120) units; ~10 notches/s
    GRAB_DEVICE = "false"       # keep raw input flowing to apps (games need it)
  '';

  # Gaming mode — pass-through. No [remap]/[movements] means makima emits no
  # remapped events, so the window sees a normal gamepad.
  gamingConfig = ''
    # Gaming mode: pass-through for this window class.
    [settings]
    GRAB_DEVICE = "false"
  '';

  # Window classes (hyprctl clients -> class) that should get gaming mode.
  # To add another game: hyprctl clients -j | jq -r '.[] | "\(.class)\t\(.title)"'
  gameClasses = [
    "net.lutris.Lutris" # Lutris game window
    "gamescope" # nested gamescope game window
    "gamescope-wl"
    ".gamescope-wrapped" # current gamescope wrapper class (Elden Ring)
    "steam" # Steam client / games without an app id
    "steam_app_1245620" # Elden Ring (Steam)
    "org.prismlauncher.PrismLauncher" # Minecraft (Prism Launcher)
    "Minecraft"
    "minecraft"
    "com.mojang.minecraft"
    "org.tlauncher.TLauncher"
    "tlauncher"
    "heroic" # Heroic Games Launcher
    "org.libretro.RetroArch" # RetroArch
  ];
in
{
  home.packages = lib.optionals enable [ makima ];

  # User service: makima needs $HOME (for ~/.config/makima) and the Hyprland
  # socket (for per-app bindings). Unit/Service/Install are the systemd section
  # names — home-manager's systemd module has no legacy `description`/`serviceConfig`.
  systemd.user.services.makima = lib.mkIf enable {
    Unit = {
      Description = "Makima gamepad remapping daemon";
      After = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${makima}/bin/makima";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  xdg.configFile = lib.mkMerge [
    (lib.mkIf enable {
      "makima/${deviceName}.toml".text = desktopConfig;
    })
    (lib.genAttrs' gameClasses (cls: {
      name = "makima/${deviceName}::${cls}.toml";
      value.text = gamingConfig;
    }))
  ];
}
