{
  config,
  pkgs,
  ...
}:
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

      # Report the active window name as the terminal title. For TUI sessions
      # this is the running app (e.g. "herdr"), "zsh"/"bash" for plain shells.
      # The Hyprland session-save script keys off this to restore TUI apps and
      # skip pure tmux-only sessions.
      set -g set-titles on
      set -g set-titles-string "#W"

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

      # Local status bar (theme-aware: every color is a #{@thm_*} reference
      # resolved at render time from the runtime theme file).
      set -g status-justify left
      set -g status-left ""
      set -g status-left-length 100
      set -g status-right-length 400

      # Window list (left). Both active and inactive get pill styling so the
      # tabs read as themed blocks instead of plain text.
      #
      # The active pill is the prefix-pending indicator: client_prefix is 1 for
      # exactly as long as tmux waits for the second key of the prefix sequence,
      # so pressing the prefix paints the current tab in the theme red and the
      # next key (or the prefix timeout) puts it straight back to @thm_accent.
      # Nothing else is needed, and no key table is taken over for it.
      #
      # The condition sits inside each colour value rather than around the whole
      # span: #{?a,b,c} splits its arguments on every comma that is not inside
      # #{...}, so a branch carrying a #[fg=..,bg=..] span loses everything from
      # that comma on. Selecting the colour keeps the spans byte for byte.
      set -g window-status-separator " "
      set -g window-status-format "#[fg=#{@thm_overlay_1},bg=#{@thm_bg}]#[fg=#{@thm_bg},bg=#{@thm_overlay_1}]#{window_index} #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #{=40:#{window_name}}#[fg=#{@thm_surface_0},bg=#{@thm_bg}]"
      set -g window-status-current-format "#[fg=#{?#{client_prefix},#{@thm_red},#{@thm_accent}},bg=#{@thm_bg}]#[fg=#{@thm_bg},bg=#{?#{client_prefix},#{@thm_red},#{@thm_accent}}]#{window_index} #[fg=#{?#{client_prefix},#{@thm_red},#{@thm_accent}},bg=#{@thm_surface_0}] #{=40:#{window_name}}#[fg=#{@thm_surface_0},bg=#{@thm_bg}]"

      # Right modules (Active Process, Sessions, Uptime).
      set -g status-right "#[fg=#{@thm_maroon},bg=#{@thm_bg}]#[fg=#{@thm_bg},bg=#{@thm_maroon}]󰇅 #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #{pane_current_command} #[fg=#{@thm_green},bg=#{@thm_surface_0}]#[fg=#{@thm_bg},bg=#{@thm_green}] #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #{session_name} #[fg=#{@thm_sapphire},bg=#{@thm_surface_0}]#[fg=#{@thm_bg},bg=#{@thm_sapphire}] #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #(${config.home.homeDirectory}/.config/tmux/uptime.sh)#[fg=#{@thm_surface_0},bg={thm_overlay_1}]"

      # Keybinds
      bind-key v split-window -v -c "#{pane_current_path}"
      bind-key b split-window -h -c "#{pane_current_path}"

      # sesh, the smart tmux session manager. It names a new session after the git
      # remote or the directory, keeps the list ordered by zoxide frecency, and
      # connects to the session if it is already running, so the picker doubles as
      # "switch" and "start here". Every command is called by its store path: a
      # long-lived tmux server keeps the PATH it was started with, so a bare
      # `sesh` would only resolve for servers started from a shell that already
      # had it.
      #
      # prefix + T picks a session in a popup. The picker is sesh's own TUI rather
      # than an fzf pipe: ctrl-x removes the row (kills a tmux session, prunes a
      # zoxide directory), ctrl-o toggles the preview, ` opens the alias view and
      # `#` numbers the rows, all without the nested $(...) quoting an fzf
      # pipeline needs inside a tmux binding.
      bind -N "smart session picker (sesh)" T display-popup -E -h 90% -w 50% "${pkgs.sesh}/bin/sesh picker -i"

      # sesh replaces the built-in last-session command, which cannot find the
      # previous session once detach-on-destroy is off (below) and a session was
      # closed rather than switched away from.
      bind -N "last-session (via sesh)" L run-shell "${pkgs.sesh}/bin/sesh last"

      # Jump to the session of the repository root, so a worktree or a subdirectory
      # pane still belongs to the same session as the rest of the checkout.
      bind -N "root session (via sesh)" 9 run-shell "${pkgs.sesh}/bin/sesh connect --root #{pane_current_path}"

      # sesh creates and switches sessions itself; without this, closing the last
      # window of a session takes the whole server (and every other session) with
      # it.
      set -g detach-on-destroy off

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
