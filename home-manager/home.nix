{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  user-packages = (import ../pkgs/default.nix { inherit pkgs inputs; }).user-packages;
in
{
  imports = [
    ../modules/config/hypr/hyprland.nix
    ../modules/config/herdr
    ../modules/config/crush
    ../modules/config/yazi
    ../modules/config/superfile
    ../modules/config/kitty
    ../modules/config/alacritty
    ../modules/config/wezterm
    ../modules/config/tmux
    ../modules/config/colors
    ../modules/config/theme
    ../modules/config/zsh
    inputs.noctalia.homeModules.default
  ];
  home.username = "zeph";
  home.homeDirectory = "/home/zeph";
  gtk.enable = true;
  stylix.targets.gtk.extraCss = ''
    @import url("noctalia.css");
  '';
  qt.enable = true;
  home.stateVersion = "26.05";
  home.pointerCursor.enable = true;
  wayland.windowManager.hyprland.configType = "lua";
  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "macchiato";
    accent = "mauve";
    # These terminals are owned by modules/config/{kitty,alacritty,wezterm,tmux}
    # which draw from the centralized colors.active palette; keep the catppuccin
    # module from also theming them.
    kitty.enable = false;
    alacritty.enable = false;
    wezterm.enable = false;
    tmux.enable = false;
  };
  xdg.configFile."gtk-3.0/gtk.css".force = true;
  xdg.configFile."hypr/hyprlock.conf".force = true;
  xdg.configFile."gtk-4.0/gtk.css".force = true;
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.kde.dolphin.desktop";
      "application/pdf" = "org.kde.okular.desktop";
    };
  };
  home.packages =
    with pkgs;
    [
    ]
    ++ user-packages;

  programs.noctalia = {
    enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
    QT_STYLE_OVERRIDE = lib.mkForce "kvantum";
    FLAKE_DIR = "/home/zeph/.config/nixos";
  };

  xdg.configFile.".gtkrc-2.0" = {
    force = true;
    text = "# Default GTK RC-2.0 Configuration\n";
  };

  # Keep dotfiles out of $HOME per XDG.
  # Relocate .Xresources to $XDG_CONFIG_HOME/X11/xresources (xrdb -merge still wired up).
  xresources.path = "${config.xdg.configHome}/X11/xresources";
  # ~/.icons would otherwise be created for backwards compat; instead rely on
  # $XDG_DATA_HOME/icons + XCURSOR_PATH (already set by home-manager).
  home.pointerCursor.dotIcons.enable = false;

  programs.home-manager.enable = true;

  # devenv shell integration: auto-activates devenv.nix dev environments on cd.
  programs.devenv = {
    enable = true;
    enableZshIntegration = true;
  };

  systemd.user.startServices = true;
  home.file.".config/wget/wgetrc" = {
    text = ''
      hsts-file = ${config.home.homeDirectory}/.local/share/wget-hsts
    '';
  };

  # programs.caelestia = {
  #   enable = true;
  #   systemd = {
  #     enable = false; # if you prefer starting from your compositor
  #     target = "graphical-session.target";
  #     environment = [ ];
  #   };
  #   settings = {
  #     bar.status = {
  #       showBattery = true;
  #     };
  #     paths.wallpaperDir = "~/Wallpaper/Catppuccin-Macchiato";
  #   };
  #   cli = {
  #     enable = true; # Also add caelestia-cli to path
  #     settings = {
  #       theme.enableGtk = true;
  #     };
  #   };
  # };

  # Include the keyboard LED control module
}
