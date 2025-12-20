{
  config,
  lib,
  pkgs,
  ...
}:

{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    image = ./wallpaper;
    cursor = {
      package = pkgs.catppuccin-cursors.macchiatoLight;
      name = "Catppuccin-Macchiato-Light-Cursors";
      size = 32;
    };
    fonts = {
      monospace = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };
      sansSerif = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };
      serif = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };
    };
    targets.hyprland.enable = true;
    targets.gtk.enable = true;
    targets.qt.enable = true;
    targets.kde.enable = false;
    targets.noctalia-shell.enable = false;
    targets.hyprland.colors.override = { "col.active_border" = "#c6a0f6"; };
  };
  home.packages = with pkgs; [
    base16-schemes
  ];
}
