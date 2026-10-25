{ config, pkgs, ... }:

let
  makima = pkgs.makima;
in
{
  # Add makima to home-manager's package list
  home.packages = [ makima ];

  # Systemd user service for makima
  # Run as a user service so it can use the user's $HOME and XDG env.
  systemd.user.services.makima = {
    description = "Makima gamepad remapper daemon";
    after = [ "default.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${makima}/bin/makima";
      Restart = "on-failure";
      RestartSec = "5s";
      # Makima needs access to /dev/input/event*; the udev rules
      # (game-devices-udev-rules) grant user-grade permissions.
      # Also ensure no login manager restricts access.
      MemoryDenyWriteExecute = false;
    };
    # Bring in the user's environment + udev uaccess
    userResources = pkgs.writeText "makima-user-resources" ''
      # Makefile-style PATH for makima (not strictly needed, but harmless)
    '';
  };

  # ── Desktop control mode configuration ──────────────────────────────
  # Default config: used when no game window is active.
  # - BTN_NORTH & BTN_WEST → scroll up/down
  # - BTN_SOUTH            → accent (left shift) + left click
  # - BTN_EAST             → decline/close (ESC)
  # - LSTICK               → control and move mouse
  # - L1/R1                → swap tabs
  xdg.configFile."makima/USB Gamepad.toml".text = ''
    # Desktop control mode for Logitech USB Gamepad
    # (default config; used when no game window is active)
    [remap]
    # Button -> key combos for desktop control
    # BTN_SOUTH -> accent (left shift) + left click
    BTN_SOUTH = ["KEY_LEFTSHIFT", "BTN_LEFT"]
    # BTN_EAST  -> decline/close (ESC)
    BTN_EAST = ["KEY_ESC"]
    # L1 (BTN_THUMBL)  -> previous tab
    BTN_THUMBL = ["KEY_LEFTALT", "KEY_TAB"]
    # R1 (BTN_THUMBR)  -> next tab
    BTN_THUMBR = ["KEY_LEFTCTRL", "KEY_TAB"]

    [movements]
    # BTN_NORTH -> scroll up
    BTN_NORTH = "SCROLL_UP"
    # BTN_WEST  -> scroll down
    BTN_WEST = "SCROLL_DOWN"

    [settings]
    LSTICK = "cursor"                      # left stick controls cursor
    LSTICK_SENSITIVITY = "6"
    LSTICK_DEADZONE = "5"
    RSTICK_SENSITIVITY = "6"
    RSTICK_DEADZONE = "64"
    GRAB_DEVICE = "false"
  '';

  # ── App-specific configurations (gaming mode pass-throughs) ─────────
  # When a game or app from the gaming list is active, these configs
  # replace the desktop control mode with a pass-through so the controller
  # works normally for that app.

  xdg.configFile."makima/USB Gamepad::com.mitchellh.ghostty.toml".text = ''
    # Gaming mode pass-through for Ghostty (TUI terminal)
    # Only minimal bindings; main input passes through to the app.
    [settings]
    LSTICK = "cursor"
    LSTICK_SENSITIVITY = "6"
    LSTICK_DEADZONE = "5"
    RSTICK_SENSITIVITY = "6"
    RSTICK_DEADZONE = "64"
    GRAB_DEVICE = "false"
  '';

  xdg.configFile."makima/USB Gamepad::chrome-gemini.google.com__-Default.toml".text = ''
    # Gaming mode pass-through for Chrome
    [settings]
    LSTICK = "cursor"
    LSTICK_SENSITIVITY = "6"
    LSTICK_DEADZONE = "5"
    RSTICK_SENSITIVITY = "6"
    RSTICK_DEADZONE = "64"
    GRAB_DEVICE = "false"
  '';

  xdg.configFile."makima/USB Gamepad::zen.toml".text = ''
    # Gaming mode pass-through for Zen Browser
    [settings]
    LSTICK = "cursor"
    LSTICK_SENSITIVITY = "6"
    LSTICK_DEADZONE = "5"
    RSTICK_SENSITIVITY = "6"
    RSTICK_DEADZONE = "64"
    GRAB_DEVICE = "false"
  '';
}
