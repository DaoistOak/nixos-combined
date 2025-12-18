{ config, pkgs, inputs, ... }:

let
  user-packages = (import ../pkgs/default.nix { inherit pkgs inputs; }).user-packages;
  spotify = import ../pkgs/spicetify.nix { inherit pkgs inputs; };
in
{
  # Force rebuild again
  imports = [
    ../config/hypr/hyprland.nix
    inputs.noctalia.homeModules.default
  ];
  home.username = "zeph";
  home.homeDirectory = "/home/zeph";
  gtk.enable = true;
  qt.enable = true;
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    spotify
    base16-schemes
  ] ++ user-packages;

   programs.noctalia-shell = {
     enable = true;
   };

   # Stylix theming
   stylix = {
     enable = true;
     base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
   };



    # Theming handled by Stylix

   xdg.configFile."gtk-4.0/gtk.css".force = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    QT_QPA_PLATFORMTHEME = "kvantum";
    QT_STYLE_OVERRIDE   = "kvantum";
  };

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;
  systemd.user.startServices = true;

  programs.caelestia = {
    enable = true;
    systemd = {
      enable = false; # if you prefer starting from your compositor
      target = "graphical-session.target";
      environment = [];
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
