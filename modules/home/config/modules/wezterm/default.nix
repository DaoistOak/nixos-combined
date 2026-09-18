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
      # Don't ask for confirmation when closing a window (WM/decoration close).
      window_close_confirmation = "NeverPrompt";
      window_background_opacity = 1.0;

      # Uniform 3-cell padding across all terminals.
      window_padding = {
        left = "3";
        right = "3";
        top = "3";
        bottom = "3";
      };

      # --- Animations: synced to the Hyprland animation profile ---
      # Display refresh is 1920x1200@60; cap render + animation FPS to that so
      # terminal redraws match compositor frames instead of tearing above vsync.
      max_fps = 60;
      animation_fps = 60;

      # Ease curves mirror Hyprland's beziers (animations/fancy.nix):
      #   fade-in  -> emphasizedDecel -> CubicBezier(0.05, 0.7, 0.1, 1)
      #   fade-out -> emphasizedAccel -> CubicBezier(0.3, 0, 0.8, 0.15)
      cursor_blink_rate = 600;
      cursor_blink_ease_in = {
        CubicBezier = [
          0.05
          0.7
          0.1
          1
        ];
      };
      cursor_blink_ease_out = {
        CubicBezier = [
          0.3
          0
          0.8
          0.15
        ];
      };
      text_blink_ease_in = {
        CubicBezier = [
          0.05
          0.7
          0.1
          1
        ];
      };
      text_blink_ease_out = {
        CubicBezier = [
          0.3
          0
          0.8
          0.15
        ];
      };
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

      -- Drop SUPER+w close-tab (clashes with Hyprland); keep CTRL/CTRL+SHIFT+w.
      local keys = config.keys or {}
      table.insert(keys, { key = 'Return', mods = 'ALT', action = wezterm.action.DisableDefaultAssignment })
      table.insert(keys, { key = 'w', mods = 'SUPER', action = wezterm.action.DisableDefaultAssignment })
      table.insert(keys, { key = 'W', mods = 'SUPER', action = wezterm.action.DisableDefaultAssignment })
      table.insert(keys, { key = 'w', mods = 'SHIFT|CTRL', action = wezterm.action.CloseCurrentTab { confirm = false } })
      table.insert(keys, { key = 'W', mods = 'CTRL', action = wezterm.action.CloseCurrentTab { confirm = false } })
      config.keys = keys

      return {}
    '';
  };
}
