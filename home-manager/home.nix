{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  user-packages = (import ../pkgs/default.nix { inherit pkgs inputs; }).user-packages;
  spotify = import ../pkgs/spicetify.nix { inherit pkgs inputs; };
in
{
  # Force rebuild again
  imports = [
    ../config/hypr/hyprland.nix
    inputs.noctalia.homeModules.default
    ./themes/theme.nix
  ];
  home.username = "zeph";
  home.homeDirectory = "/home/zeph";
  gtk.enable = true;
  qt.enable = true;
  home.stateVersion = "24.11";
  home.packages =
    with pkgs;
    [
      spotify
    ]
    ++ user-packages;

  programs.noctalia-shell = {
    enable = true;
    colors.mPrimary = lib.mkForce config.lib.stylix.colors.withHashtag.base0E;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    QT_QPA_PLATFORMTHEME = lib.mkForce "kvantum";
    QT_STYLE_OVERRIDE = lib.mkForce "kvantum";
    FLAKE_DIR = "/home/zeph/.config/nixos";
  };

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;
  systemd.user.startServices = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.caelestia = {
    enable = true;
    systemd = {
      enable = false; # if you prefer starting from your compositor
      target = "graphical-session.target";
      environment = [ ];
    };
    settings = {
      bar.status = {
        showBattery = true;
      };
      paths.wallpaperDir = "~/Wallpaper/Catppuccin-Macchiato";
    };
    cli = {
      enable = true; # Also add caelestia-cli to path
      settings = {
        theme.enableGtk = true;
      };
    };
  };

  # Include the keyboard LED control module
}
