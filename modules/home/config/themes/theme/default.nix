{
  config,
  lib,
  pkgs,
  ...
}:

let
  t = import ../colors/themes.nix { inherit lib; };
  sel = t.readSelection ../colors/src/selection;
in
{
  stylix = {
    enable = true;
    polarity = sel.r.polarity;
    # Wallpaper disabled: hyprwinwrap widgets provide the backdrop.
    # Theming is driven by base16Scheme below, which is independent of image.
    image = null;
    # Derived from the active theme selection (modules/home/config/themes/colors/src/selection,
    # updated by scripts/theme), so switching theme/accent and rebuilding makes
    # Stylix' GTK/KDE/Qt outputs follow. base0D carries the selected accent.
    base16Scheme = t.toBase16 sel.r;
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
    # No wallpaper: disables the auto-hyprpaper systemd unit
    targets.hyprland.image.enable = false;
    targets.gtk.enable = true;
    targets.qt.enable = true;
    targets.kde.enable = true;
    targets.kde.useWallpaper = false;
    targets.kde.decorations = "org.kde.klassy";
    targets.kde.decorationTheme = "klassy";
    # Plasma desktop theme (plasmarc [Theme] name). This is NOT the Kvantum
    # widget style: setting it to "kvantum-dark" pointed Plasma at a desktop
    # theme that does not exist, so its SVG/frame assets failed to load and the
    # wallpaper/desktop settings misbehaved. Use the stock Breeze theme that
    # follows the active color scheme instead.
    targets.kde.applicationStyle =
      if config.colors.active.polarity == "light" then "breeze-light" else "breeze-dark";
    targets.kde.widgetStyle = "qtcde";
    targets.noctalia-shell.enable = false;
    # Terminals/dotfiles are owned by the declarative modules under
    # modules/config/{kitty,alacritty,wezterm,tmux} which draw from the
    # centralized colors.active palette; keep Stylix from re-theming them.
    targets.kitty.enable = false;
    targets.alacritty.enable = false;
    targets.wezterm.enable = false;
    targets.ghostty.enable = false;
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
