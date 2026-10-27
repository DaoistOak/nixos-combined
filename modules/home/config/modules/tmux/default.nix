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

    # Home-manager emits each plugin's `extraConfig` immediately before its
    # `run-shell`, and the whole plugin block before the global `extraConfig`
    # at the bottom of this file. An option a plugin reads while binding its
    # keys -- floax's @floax-bind -- therefore has
    # to be set in that plugin's own extraConfig: written into `extraConfig`
    # below it would arrive one step too late and the plugin would keep its
    # default binding.
    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
      fingers
      fuzzback
      extrakto
      pain-control
      copy-toolkit
      tmux-which-key
      vim-tmux-focus-events
      {
        plugin = tmux-floax;
        extraConfig = ''
          # prefix + Space toggles the floating pane. floax binds this itself
          # in floax.tmux, so there is no bind to write out here -- only the
          # key it should claim.
          set -g @floax-bind "Space"
        '';
      }
    ];

    extraConfig = ''
      # Terminal + kitty graphics protocol support
      set -g default-terminal "tmux-256color"
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
      set -g status-right "#[fg=#{@thm_maroon},bg=#{@thm_bg}]#[fg=#{@thm_bg},bg=#{@thm_maroon}]󰇅 #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #{pane_current_command} #[fg=#{@thm_green},bg=#{@thm_surface_0}]#[fg=#{@thm_bg},bg=#{@thm_green}] #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #{session_name} #[fg=#{@thm_sapphire},bg=#{@thm_surface_0}]#[fg=#{@thm_bg},bg=#{@thm_sapphire}] #[fg=#{@thm_fg},bg=#{@thm_surface_0}] #(${config.home.homeDirectory}/.config/tmux/uptime.sh)#[fg=#{@thm_surface_0},bg=#{@thm_bg}]"

      # Keybinds
      bind-key v split-window -v -c "#{pane_current_path}"
      bind-key b split-window -h -c "#{pane_current_path}"

      # Better pane navigation (vim-tmux-navigator handles vim-aware navigation)
      bind-key -r h select-pane -L
      bind-key -r j select-pane -D
      bind-key -r k select-pane -U
      bind-key -r l select-pane -R

      # Resize panes
      bind-key -r H resize-pane -L 5
      bind-key -r J resize-pane -D 5
      bind-key -r K resize-pane -U 5
      bind-key -r L resize-pane -R 5

      # Window navigation
      bind-key -r C-h previous-window
      bind-key -r C-l next-window

      # Swap windows
      bind-key -r "<" swap-window -t -1
      bind-key -r ">" swap-window -t +1

      # Kill pane/window/session
      bind-key x kill-pane
      bind-key X kill-window
      bind-key C-x confirm-before -p "kill session #S? (y/n)" kill-session

      # Reload config
      bind-key R source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      # Copy mode improvements
      set -g mode-keys vi
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel

      # tmux-floax: floating pane is bound by floax.tmux from @floax-bind
      # (prefix + Space) -- see the plugin entry above. The old
      # `bind-key F run-shell "#{@floax-bind}"` is gone: it expanded to the
      # option's value and then handed that string to the shell as a command.

      # tmux-which-key: show keybindings
      set -g @tmux-which-key-delay 0

      # fingers: jump to text (prefix + g)
      set -g @fingers-key g
      set -g @fingers-copy-command "xclip -selection clipboard"
      set -g @fingers-compact-hints 0

      # fuzzback: fuzzy scrollback search (prefix + f)
      set -g @fuzzback-popup 1
      set -g @fuzzback-popup-size "90%"
      set -g @fuzzback-bind "f"

      # extrakto: fuzzy find text (prefix + e)
      set -g @extrakto_key "e"
      set -g @extrakto_popup_size "80%"
      set -g @extrakto_filter_order "all line word path url quote"

      # yank: clipboard integration
      set -g @yank_selection_mouse "clipboard"
      set -g @yank_action "copy-pipe-and-cancel"
      set -g @yank_with_mouse on

      # pain-control: already provides good bindings, ensure they're loaded
      # copy-toolkit: provides additional copy mode tools

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
      #
      # prefix + s also opens the sesh picker (was sessionx's @sessionx-bind "s",
      # now dropped; sesh reuses the same sesh picker binary).
      bind -N "smart session picker (sesh)" s display-popup -E -h 90% -w 50% "${pkgs.sesh}/bin/sesh picker -i"
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

  # Uptime helper: formats /proc/uptime into exactly two parts (see status-right).
  home.file.".config/tmux/uptime.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      secs=$(awk '{printf "%d", $1}' /proc/uptime)
      w=$((secs / 604800))
      d=$(((secs % 604800) / 86400))
      h=$(((secs % 86400) / 3600))
      m=$(((secs % 3600) / 60))
      s=$((secs % 60))
      if [ "$w" -gt 0 ]; then
        printf '%dw %dd' "$w" "$d"
      elif [ "$d" -gt 0 ]; then
        printf '%dd %dh' "$d" "$h"
      elif [ "$h" -gt 0 ]; then
        printf '%dh %dm' "$h" "$m"
      else
        printf '%dm %ds' "$m" "$s"
      fi
    '';
  };
}
