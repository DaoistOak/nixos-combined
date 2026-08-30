{
  config,
  lib,
  pkgs,
  ...
}:
# WezTerm: static config (font, window, launch) via home-manager programs.wezterm.
# Colors are NOT baked in — they come from the runtime theme file
# (~/.config/theme-switcher/wezterm-theme.lua) that scripts/theme rewrites on
# ./theme set ... (no rebuild). add_to_config_reload_watch_list makes wezterm
# hot-reload as soon as that file changes.
{
  programs.wezterm = {
    enable = true;
    package = pkgs.wezterm;

    settings = {
      font = lib.generators.mkLuaInline "wezterm.font(\"JetBrainsMono Nerd Font\")";
      font_size = 10.0;
      hide_tab_bar_if_only_one_tab = true;
      window_decorations = "RESIZE";
      default_prog = [ "zsh" ];
    };

    extraConfig = ''
      -- Runtime-swappable colors. scripts/theme rewrites this file on ./theme set ...
      local home = os.getenv("HOME")
      local theme_file = home .. "/.config/theme-switcher/wezterm-theme.lua"
      local ok, theme = pcall(dofile, theme_file)
      if ok and type(theme) == "table" then
        for k, v in pairs(theme) do
          config[k] = v
        end
      end
      -- Hot-reload whenever the theme file changes.
      wezterm.add_to_config_reload_watch_list(theme_file)
      return {}
    '';
  };
}
