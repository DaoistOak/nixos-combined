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

      # ------------------------------------------------------------------
      # Native pill status bar (no theming plugin).
      #
      # COLORS are NOT baked in — they come from runtime tmux variables
      # (@thm_tab_*, @thm_m_*) defined in ~/.config/theme-switcher/tmux-theme.conf
      # (rewritten by scripts/theme on ./theme set ... and sourced at the end).
      # The format strings use `set -g` (not -gF), so the #{@thm_*} refs expand
      # at render time and a theme switch recolors the whole bar with no rebuild.
      # The pill half-circle separator glyphs are  (left) and  (right).
      #
      # Transparent bar, tabs left-justified, modules on the right.
      set -g status-style "bg=default"
      set -g status-justify left
      set -g status-left ""
      set -g status-left-length 100
      set -g status-right-length 150

      # --- WINDOW TABS (Left side) ---
      # Each tab: pill (index) + body (name). One quoted value per command.
      set -g window-status-format "#[fg=#{@thm_tab_inactive},bg=default] #[fg=#{@thm_on_pill},bg=#{@thm_tab_inactive}] #I #[fg=#{@thm_tab_fg},bg=#{@thm_tab_bg}] #W #[fg=#{@thm_tab_bg},bg=default]"
      set -g window-status-current-format "#[fg=#{@thm_tab_accent},bg=default] #[fg=#{@thm_on_pill},bg=#{@thm_tab_accent}] #I #[fg=#{@thm_tab_fg},bg=#{@thm_tab_bg}] #W #[fg=#{@thm_tab_bg},bg=default]"
      set -g window-status-separator ""

      # --- STATUS MODULES (Right side) ---
      # Each module is a pill: colored icon+body segment.
      set -g status-right ""
      set -ag status-right "#[fg=#{@thm_m_user},bg=default] #[fg=#{@thm_on_pill},bg=#{@thm_m_user}]  #[fg=#{@thm_tab_fg},bg=#{@thm_tab_bg}] #(basename "$SHELL") #[fg=#{@thm_tab_bg},bg=default]"
      set -ag status-right "#[fg=#{@thm_m_battery},bg=default] #[fg=#{@thm_on_pill},bg=#{@thm_m_battery}] #[fg=#{@thm_tab_fg},bg=#{@thm_tab_bg}] #(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo ?)% #[fg=#{@thm_tab_bg},bg=default]"
      set -ag status-right "#[fg=#{@thm_m_cpu},bg=default] #[fg=#{@thm_on_pill},bg=#{@thm_m_cpu}] #[fg=#{@thm_tab_fg},bg=#{@thm_tab_bg}] #(ps -eo %cpu --sort=-%cpu | head -2 | tail -1 | tr -d ' ')% #[fg=#{@thm_tab_bg},bg=default]"
      set -ag status-right "#[fg=#{@thm_m_uptime},bg=default] #[fg=#{@thm_on_pill},bg=#{@thm_m_uptime}] #[fg=#{@thm_tab_fg},bg=#{@thm_tab_bg}] #(uptime -p | sed 's/^up //; s/,.*//') #[fg=#{@thm_tab_bg},bg=default]"

      # Keybinds
      bind-key v split-window -v -c "#{pane_current_path}"
      bind-key b split-window -h -c "#{pane_current_path}"

      # Runtime theme (rewritten by scripts/theme, no rebuild to switch).
      source-file ~/.config/theme-switcher/tmux-theme.conf
    '';
  };
}
