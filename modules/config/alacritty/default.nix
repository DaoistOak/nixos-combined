{
  config,
  lib,
  pkgs,
  ...
}:
# Alacritty: static config (font, live reload) via home-manager programs.alacritty.
# Colors are NOT baked in — they come from the runtime theme file
# (~/.config/theme-switcher/alacritty-theme.toml) that scripts/theme rewrites on
# ./theme set ... (no rebuild). live_config_reload picks up changes automatically.
{
  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;

    settings = {
      live_config_reload = true;

      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font";
        };
        size = 10;
        builtin_box_drawing = true;
      };

      # Runtime-swappable colors (scripts/theme rewrites the imported file).
      general.import = [
        "~/.config/theme-switcher/alacritty-theme.toml"
      ];
    };
  };
}
