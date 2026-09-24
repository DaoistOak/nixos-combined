// Tab-completion menu: mirror oh-my-zsh's lib/completion.zsh so the first Tab
// lists candidates, a second Tab enters the picker, and Enter accepts the
// highlighted match (e.g. `cd .config/nixo<Tab><Tab>` then Enter goes into
// nixos/). `special-dirs` also offers `..` and `.` entries in `cd`.
unsetopt menu_complete
setopt auto_menu
setopt complete_in_word
setopt always_to_end
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

// Global aliases (substitute anywhere in a command line).
alias -g ls='eza --icons -a --color=always --group-directories-first'
alias -g la='eza --icons -al --color=always --group-directories-first'
alias -g cls='clear'
alias -g instl='sudo nixos-rebuild switch --show-trace --impure --flake ~/.config/nixos#Lingnao'
alias -g clean='sudo nix-env --delete-generations old && sudo nix-collect-garbage -d'
alias -g cat='bat'
alias -g rr='curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | bash'
alias -g parrot='curl parrot.live'
alias -g portainer='sudo docker start Portainer'
alias -g dotfiles='git --git-dir=/home/zeph/.dotfiles --work-tree=/home/zeph'
alias -g web='qutebrowser'
alias -g weather='curl wttr.in/kathmandu'
alias -g greet='cermic 1 ~/Pictures/cermic/'
alias -g al='ollama run Alfred'
alias -g nix-shell='nix-shell --run zsh'
alias -g hm='home-manager switch --flake ~/.config/nixos#zeph'
alias -g nix-init="~/bin/nix-shell-boilerplate.sh"
alias -g vi='edit_file'
alias -g wget='wget --hsts-file="$XDG_DATA_HOME/wget-hsts"'
alias -g dosbox='dosbox -conf "$XDG_CONFIG_HOME"/dosbox/dosbox.conf'
alias -g tabby_start='sudo tabby serve --model DeepSeekCoder-1.3B --chat-model Qwen3-4B --device rocm'

// sudo: prepend/remove "sudo " on the current line (Ctrl-X Ctrl-S; omz sudo plugin).
sudo-command-line() {
  [[ -z $BUFFER ]] && zle up-history
  if [[ $BUFFER == "sudo "* ]]; then
    LBUFFER="${LBUFFER#sudo }"
  elif [[ $BUFFER == "sudo sudo "* ]]; then
    LBUFFER="${LBUFFER#sudo }"
  else
    LBUFFER="sudo $LBUFFER"
  fi
}
zle -N sudo-command-line
bindkey -M emacs '^Xs' sudo-command-line
bindkey -M viins '^Xs' sudo-command-line
bindkey -M vicmd '^Xs' sudo-command-line

// Git helper functions used by the gcm/gpsup aliases.
git_main_branch() {
  command git rev-parse --git-dir >/dev/null 2>&1 \
    && command git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
}
git_current_branch() {
  command git symbolic-ref --quiet HEAD 2>/dev/null | sed 's@^refs/heads/@@'
}

// you-should-use: after a command finishes, remind you if a defined alias is
// exactly it (manual; replaces oh-my-zsh plugins/you-should-use).
autoload -Uz add-zsh-hook
you-should-use() {
  local cmd
  cmd=$(fc -ln -1 2>/dev/null)
  cmd=${cmd#"${cmd%%[![:space:]]*}"}
  [[ -z $cmd ]] && return
  [[ $cmd == *';'* || $cmd == *'&&'* || $cmd == *'||'* ]] && return
  [[ ${cmd%% *} == sudo ]] && return

  local name
  for name in ${(k)aliases}; do
    if [[ $cmd == "${aliases[$name]}" ]]; then
      print -rP "%F{yellow}You should use:%f %B${name}%b"
      print -rP "%F{245}  you typed:%f %F{245}${cmd//\%/%%}%f"
      return 0
    fi
  done
}
add-zsh-hook precmd you-should-use

// autonotify: desktop notification via notify-send when a command finishes if
// it ran for at least AUTONOTIFY_THRESHOLD seconds (manual; replaces
// oh-my-zsh plugins/autonotify).
zmodload -i zsh/datetime
AUTONOTIFY_THRESHOLD=60
_autonotify_preexec() {
  _autonotify_start=$EPOCHREALTIME
  _autonotify_cmd=$1
}
_autonotify_precmd() {
  if [[ -n $_autonotify_start ]]; then
    local elapsed cmd
    elapsed=$(( EPOCHREALTIME - _autonotify_start ))
    if (( elapsed >= AUTONOTIFY_THRESHOLD )); then
      cmd=${_autonotify_cmd%%$'\n'*}
      notify-send --urgency=critical --expire-time=8000 \
        "Command finished" "$cmd took ${elapsed%.*}s" 2>/dev/null
    fi
    unset _autonotify_start
  fi
}
add-zsh-hook preexec _autonotify_preexec
add-zsh-hook precmd _autonotify_precmd

// edit_file: nvim for writable files, sudoedit otherwise (or create).
edit_file() {
  if [[ -e "$1" ]]; then
    if [[ -f "$1" ]]; then
      if [[ -w "$1" ]]; then
        echo "[Regular file] Editing: $1"
        nvim "$1"
      else
        echo "[SU file] Editing as root: $1"
        sudoedit "$1"
      fi
    else
      echo "Error: '$1' is not a regular file."
      return 1
    fi
  else
    echo "File '$1' does not exist. Create it? (Y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      dir=$(dirname "$1")
      if [[ -w "$dir" ]]; then
        touch "$1"
        echo "File created: $1"
        nvim "$1"
      else
        echo "No write permission. Create with sudo? (Y/N)"
        read -r sudo_response
        if [[ "$sudo_response" =~ ^[Yy]$ ]]; then
          sudo touch "$1" && sudo chown "$USER:$USER" "$1"
          echo "File created with sudo: $1"
          sudoedit "$1"
        else
          echo "Aborted."
          return 1
        fi
      fi
    else
      echo "Aborted."
      return 1
    fi
  fi
}

// chpwd hooks: run on every directory change.
autoload -Uz add-zsh-hook

// Re-source the theme-switcher's p10k overrides on every prompt so a
// mid-session `./theme set ...` recolors POWERLEVEL9K_DIR_BACKGROUND (and any
// future p10k overrides) on the next render.
theme_p10k_sync() {
  [[ -f "$HOME/.config/theme-switcher/p10k-theme.zsh" ]] && source "$HOME/.config/theme-switcher/p10k-theme.zsh"
}
add-zsh-hook precmd theme_p10k_sync

// 1) List directory contents after every cd (mirrors the `ls` alias).
chpwd_ls() {
  setopt localoptions aliases
  command eza --icons -a --color=always --group-directories-first
}
add-zsh-hook chpwd chpwd_ls

// 2) Auto-activate a local environment: source a python venv, or enter a
//    nix-shell when shell.nix is present (guarded against recursion).
chpwd_autoenv() {
  local vd
  for vd in .venv venv; do
    if [[ -f "$vd/bin/activate" && -z "$VIRTUAL_ENV" ]]; then
      source "$vd/bin/activate"
      echo "Activated virtualenv: $vd"
      break
    fi
  done

  if [[ -f shell.nix && -z "$IN_NIX_SHELL" ]]; then
    echo "shell.nix detected. Starting nix-shell..."
    exec nix-shell --run zsh
  fi
}
add-zsh-hook chpwd chpwd_autoenv

// Greater prompt (runs after every alias above is defined).
greet
echo "\n"