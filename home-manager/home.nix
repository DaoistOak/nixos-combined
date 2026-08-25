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
    ../config/hypr/hyprland.nix
    inputs.noctalia.homeModules.default
    ./themes/theme.nix
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
  };
  xdg.configFile."gtk-3.0/gtk.css".force = true;
  xdg.configFile."hypr/hyprlock.conf".force = true;
  xdg.configFile."gtk-4.0/gtk.css".force = true;
  xdg.configFile."mimeapps.list".force = true;
  home.file.".config/quickshell/overview".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nixos/_git-clones/quickshell-overview";
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
  programs.home-manager.enable = true;
  systemd.user.startServices = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
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
