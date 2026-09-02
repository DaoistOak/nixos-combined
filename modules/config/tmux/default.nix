{
  config,
  lib,
  pkgs,
  ...
}:
# Tmux: terminal features, keybinds and a self-contained local status bar
# (no catppuccin/tmux plugin) following the "TUI pill" architecture:
#
#   [Left: window list]                    [Right: four pills on slate]
#   ╭╮ ╭───╮ ╭────────────────────╮      ╭╮ ╭───╮ ╭──────╮ ╭...
#   │ │ │ 1 │ │ .../path           │      │ │ │  │ │ zsh  │ │ ...
#
# Layout:
#   * Window list anchored far-left via `status-justify left`; the active
#     window is a mint-green pill (index) + muted-slate path block.
#   * status-left is empty; tmux fills the center gap with the transparent/
#     base background.
#   * The four right modules (Active Process, Sessions, User, Uptime) live in
#     one status-right string, each an  left-cap pill ending in a flat edge.
#
# Theming: all colors come from the @thm_* tmux variables written to
# ~/.config/theme-switcher/tmux-theme.conf by scripts/theme (and by
# modules/config/colors at build time), so ./theme set ... recolors the whole
# bar at runtime — no plugin rebake needed.
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

      # ------------------------------------------------------------------
      # Local status bar (theme-aware: every color is a #{@thm_*} reference
      # resolved at render time from the runtime theme file).
      # ------------------------------------------------------------------
      set -g status-justify left
      set -g status-left ""
      set -g status-left-length 100
      set -g status-right-length 400

      # Window list (left). Active window: mint pill index + slate path.
      set -g window-status-separator " "
      set -g window-status-format " #[fg=#{@thm_overlay_1},bg=#{@thm_bg}]#{window_index}:#{window_name} "
      set -g window-status-current-format "#[fg=#{@thm_accent},bg=colour0]#[fg=#{@thm_bg},bg=#{@thm_accent}]#{window_index} #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #{=40:#{window_name}} #[fg=#{@thm_surface_0},bg=#{@thm_bg}]"

      # Right modules (Active Process, Sessions, Uptime).
      set -g status-right "#[fg=#{@thm_maroon},bg=#{@thm_bg}]#[fg=#{@thm_bg},bg=#{@thm_maroon}]󰇅󰟀 #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #{pane_current_command} #[default] #[fg=#{@thm_green},bg=#{@thm_bg}]#[fg=#{@thm_bg},bg=#{@thm_green}] #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #{session_windows} #[default] #[fg=#{@thm_sapphire},bg=#{@thm_bg}]#[fg=#{@thm_bg},bg=#{@thm_sapphire}] #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #(${config.home.homeDirectory}/.config/tmux/uptime.sh) #[fg=#{@thm_surface_0},bg=colour0]"

      # Keybinds
      bind-key v split-window -v -c "#{pane_current_path}"
      bind-key b split-window -h -c "#{pane_current_path}"

      # Runtime theme. Defines @thm_* (referenced lazily above) + base styles;
      # rewritable by scripts/theme for hot-swapping.
      source-file ~/.config/theme-switcher/tmux-theme.conf
    '';
  };

  # Uptime helper: formats /proc/uptime as "1 day 8h 21m" (see status-right).
  home.file.".config/tmux/uptime.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      secs=$(awk '{printf "%d", $1}' /proc/uptime)
      d=$((secs / 86400))
      h=$(((secs % 86400) / 3600))
      m=$(((secs % 3600) / 60))
      if [ "$d" -gt 0 ]; then
        pl="s"; [ "$d" -eq 1 ] && pl=""
        printf '%d day%s %dh %dm' "$d" "$pl" "$h" "$m"
      elif [ "$h" -gt 0 ]; then
        printf '%dh %dm' "$h" "$m"
      else
        printf '%dm' "$m"
      fi
    '';
  };
}
