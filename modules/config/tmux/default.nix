{
  config,
  lib,
  pkgs,
  ...
}:
# Tmux: terminal features, keybinds and the official catppuccin/tmux status bar
# via home-manager programs.tmux (tmuxPlugins.catppuccin).
#
# Runtime theme switching: the catppuccin plugin sources a per-flavor
# themes/catppuccin_<flavor>_tmux.conf that defines @thm_* colors, and builds the
# bar from #{@thm_*} format strings that expand lazily at render time. We pick a
# base flavor for the plugin, then source ~/.config/theme-switcher/tmux-theme.conf
# (rewritten by scripts/theme on ./theme set ...) AFTER the plugin so its @thm_*
# values override the flavor defaults — recoloring the whole bar on every switch
# with no rebuild.
{
  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    baseIndex = 1;
    escapeTime = 0;
    mouse = true;

    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      {
        plugin = catppuccin;
        # These options are read by the plugin at load time (before its
        # run-shell), so they must be set here in the plugin's own extraConfig —
        # the main extraConfig runs after all plugins.
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"
        '';
      }
    ];

    extraConfig = ''
      # Terminal + kitty graphics protocol support
      set-option -sa terminal-overrides ",xterm*:Tc"
      set-option -sa terminal-overrides ",konsole*:Tc"
      set-option -sa terminal-overrides ",kitty*:Tc"
      set -g terminal-features ",*:extkeys"
      set -g terminal-features ",*:sixel"
      set -g terminal-features ",*:kitty"
      set -g terminal-features ",*:ms"
      set -ga terminal-features ',*:sync'

      # Window switching
      unbind n
      unbind p
      bind n new-window
      bind -n M-P previous-window
      bind -n M-L next-window

      # Window/pane numbering
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Status line module pills (self-contained — no extra tmux plugins needed).
      # The catppuccin plugin defines @catppuccin_status_<module>; runtime @thm_*
      # overrides (sourced at the end) recolor them on every theme switch.
      set -g status-left-length 100
      set -g status-right-length 150
      set -g status-left ""
      set -g status-right "#{E:@catppuccin_status_application}"
      set -ag status-right "#{E:@catppuccin_status_session}"
      set -ag status-right "#{E:@catppuccin_status_user}"
      set -ag status-right "#{E:@catppuccin_status_uptime}"

      # Keybinds
      bind-key v split-window -v -c "#{pane_current_path}"
      bind-key b split-window -h -c "#{pane_current_path}"

      # Runtime theme. Sourced AFTER the plugin so our @thm_* values override the
      # flavor defaults; rewritable by scripts/theme for hot-swapping.
      source-file ~/.config/theme-switcher/tmux-theme.conf
    '';
  };
}
