{
  config,
  lib,
  pkgs,
  ...
}:
# Ghostty: static config via home-manager programs.ghostty. Colors are NOT baked
# in — the `theme` key names the built-in Ghostty theme matching the tracked
# selection, and the accent-driven primary slots (bg/fg/cursor/selection) come
# from a runtime override file (~/.config/theme-switcher/ghostty-theme.conf)
# that scripts/theme rewrites on ./theme set ... (no rebuild). config-file is
# processed at the end, so it wins over the built-in, and ghostty
# +reload-config re-applies it live.
let
  # Reuse the shared theme DB to resolve the built-in Ghostty theme for the
  # currently tracked selection (matches what scripts/theme writes at runtime).
  t = import ../../themes/colors/themes.nix { inherit lib; };
  sel = t.readSelection ../../themes/colors/src/selection;
  ghosttyBuiltin =
    t.themes.${sel.themeName}.flavors.${sel.flavorName}.ghostty or "Ghostty Default Style Dark";
in
{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;

    settings = {
      # Fonts
      font-family = "JetBrainsMono Nerd Font";
      font-size = 10;
      font-thicken = true;

      # Cursor
      cursor-style = "bar";
      cursor-style-blink = true;

      # Cursor trail (Neovide-style): bends a brush-stroke trail behind the
      # caret as it moves between cells. custom-shader-animation = always keeps
      # the trail animated even when the bar cursor turns hollow on unfocus.
      custom-shader = "${config.home.homeDirectory}/.config/ghostty/shaders/wisp-cursor.glsl";
      custom-shader-animation = "always";

      # Scrollback
      scrollback-limit = 2000;

      # Window
      window-padding-x = 3;
      window-padding-y = 3;
      # Server-side decorations so Hyprland draws the title (mirrors kitty).
      gtk-titlebar = false;
      confirm-close-surface = false;

      # Fully opaque in-app; Hyprland applies the uniform 0.90 transparency
      # (see the whitelist in hypr/.../settings/keybinds.nix).
      background-opacity = 1.0;

      # Runtime-swappable colors: built-in Ghostty theme for the selection +
      # primary-color overrides. scripts/theme rewrites the config-file.
      theme = ghosttyBuiltin;
      config-file = "${config.home.homeDirectory}/.config/theme-switcher/ghostty-theme.conf";
    };
  };

  # Vendored cursor-trail shader (MIT, hced/ghostty-cursor-trails).
  xdg.configFile."ghostty/shaders/wisp-cursor.glsl" = {
    source = ./src/wisp-cursor.glsl;
    force = true;
  };
}
