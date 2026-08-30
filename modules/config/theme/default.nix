{
  config,
  lib,
  pkgs,
  ...
}:

{
  stylix = {
    enable = true;
    polarity = "dark";
    image = ./wallpaper;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    override.base0D = "c6a0f6";
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
    targets.hyprland.image.enable = true;
    targets.gtk.enable = true;
    targets.qt.enable = true;
    targets.kde.enable = true;
    targets.kde.useWallpaper = false;
    targets.kde.decorations = "org.kde.klassy";
    targets.kde.decorationTheme = "klassy";
    targets.kde.applicationStyle = "kvantum-dark";
    targets.kde.widgetStyle = "qtcde";
    targets.noctalia-shell.enable = false;
    # Terminals/dotfiles are owned by the declarative modules under
    # modules/config/{kitty,alacritty,wezterm,tmux} which draw from the
    # centralized colors.active palette; keep Stylix from re-theming them.
    targets.kitty.enable = false;
    targets.alacritty.enable = false;
    targets.wezterm.enable = false;
    targets.tmux.enable = false;
    # Stylix's gtksourceview overlay (applied via nixpkgs.overlays in HM)
    # changes gtksourceview's hash, forcing inkscape and catppuccin-cursors
    # to compile locally on every nixpkgs bump. No gtksourceview-based editor
    # is used.
    targets.gtksourceview.enable = false;
    # yazi themed by catppuccin (modules/config/yazi) with the macchiato-mauve
    # flavor file instead of stylix's base16 scheme.
    targets.yazi.enable = false;
    # targets.hyprland.colors.override = {
    #   "col.active_border" = "#c6a0f6";
    # };
  };
  home.packages = with pkgs; [
    base16-schemes
  ];
}
