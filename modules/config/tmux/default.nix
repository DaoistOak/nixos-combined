{
  config,
  lib,
  pkgs,
  ...
}:
# Tmux: static config (terminal features, status layout, keybinds, plugins) via
# home-manager programs.tmux. Colors are NOT baked in — they live in
# ~/.config/theme-switcher/tmux-theme.conf (rewritten by scripts/theme on
# ./theme set ...) and are loaded with source-file, so no rebuild to switch and
# the same file themes any theme in the DB.
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

      # Status layout (colors come from the runtime theme file)
      set -g status-left-length 40
      set -g status-right-length 60
      set -g status-left "#[bg=]=#S"
      set -g status-right "#H"

      # Keybinds
      bind-key v split-window -v -c "#{pane_current_path}"
      bind-key b split-window -h -c "#{pane_current_path}"

      # Runtime theme (rewritten by scripts/theme, no rebuild to switch).
      source-file ~/.config/theme-switcher/tmux-theme.conf
    '';
  };
}
