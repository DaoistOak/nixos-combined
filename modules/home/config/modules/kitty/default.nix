{
  config,
  lib,
  pkgs,
  ...
}:
# Kitty: static config via home-manager programs.kitty. Colors are NOT baked in
# here — they come from a runtime theme file (~/.config/theme-switcher/kitty-theme.conf)
# that scripts/theme rewrites on ./theme set ... (no rebuild). Total runtime
# hot-swap, and the same file works for any theme in the DB (Catppuccin, Dracula, ...).
{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;

    settings = {
      # Fonts
      font_family = "JetBrainsMono Nerd Font";
      font_size = 10.0;
      adjust_line_height = "100%";
      adjust_column_width = "100%";

      # Cursor
      cursor_shape = "beam";
      cursor_blink_interval = 1;

      # Scrollback
      scrollback_lines = 2000;
      wheel_scroll_multiplier = 5.0;
      touch_scroll_multiplier = 1.0;

      # Mouse
      url_style = "curly";
      open_url_with = "default";
      copy_on_select = true;

      # Window
      window_padding_width = 2.65;
      hide_window_decorations = false;
      confirm_os_window_close = 0;

      # Tab bar
      tab_bar_min_tabs = 2;
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";

      # Background (transparent-ish)
      background_opacity = 0.60;
      dynamic_background_opacity = true;

      # Shell / term
      shell = ".";
      term = "kitty";
      kitty_mod = "ctrl+shift";
    };

    keybindings = {
      "kitty_mod+l" = "next_layout";
      "ctrl++" = "change_font_size all +1.0";
      "ctrl+-" = "change_font_size all -1.0";
      "f11" = "toggle_fullscreen";
      "kitty_mod++" = "set_background_opacity +0.1";
      "kitty_mod+-" = "set_background_opacity -0.1";
      "ctrl+l" = "combine : clear_terminal scroll active : send_text normal,application \\x0c";
    };

    # Colors are runtime-swappable. kitty re-reads the include on SIGUSR1.
    extraConfig = ''
      include ${config.home.homeDirectory}/.config/theme-switcher/kitty-theme.conf
    '';
  };
}
