{
  config,
  lib,
  pkgs,
  ...
}:
# Kitty: static config via home-manager programs.kitty. Colors are runtime-swappable
# via ~/.config/theme-switcher/kitty-theme.conf (rewritten by scripts/theme, no rebuild).
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

      # Window: uniform 3-cell padding across all terminals.
      window_padding_left = 3;
      window_padding_right = 3;
      window_padding_top = 3;
      window_padding_bottom = 3;
      hide_window_decorations = false;
      confirm_os_window_close = 0;

      # Tab bar
      tab_bar_min_tabs = 2;
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";

      # Fully opaque in-app; Hyprland applies uniform 0.90 transparency.
      background_opacity = 1.0;
      dynamic_background_opacity = false;

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
      "ctrl+l" = "combine : clear_terminal scroll active : send_text normal,application \\x0c";
    };

    # Colors from runtime theme file; kitty re-reads on SIGUSR1.
    extraConfig = ''
      include ${config.home.homeDirectory}/.config/theme-switcher/kitty-theme.conf
    '';
  };
}
