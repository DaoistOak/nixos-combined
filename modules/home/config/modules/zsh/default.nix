{
  config,
  lib,
  pkgs,
  ...
}:
let
  zshDir = "${config.xdg.configHome}/zsh";

  powerlevel10k = pkgs.fetchFromGitHub {
    owner = "romkatv";
    repo = "powerlevel10k";
    rev = "3308262dfbd743b6e1d3956a2b5572f7a049d692";
    hash = "sha256-s0FLaSZdhMTJyHQFtkQWdp0Qi2QAZvy4H40r1FdEOvY=";
  };
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = zshDir;
    defaultKeymap = "viins";

    history = {
      path = "${zshDir}/.zsh_history";
      size = 10000000;
      save = 10000000;
    };

    envExtra = ''
      export PATH="$PATH:$HOME/bin"
      export PATH="$PATH:/home/zeph/.spicetify"
      export ZSH_TMUX_AUTOSTART_ONC_ONCE=true
      export ZSH_TMUX_DEFAULT_SESSION_NAME=Base
      export NIX_LD_LIBRARY_PATH=$(nix eval --raw nixpkgs#glibc.outPath)/lib
      export TERM=tmux-256color
      export NIXPKGS_ALLOW_UNFREE=1
    '';

    initContent = lib.mkMerge [
      (lib.mkOrder 500 (builtins.readFile ./src/init.zsh))
      (lib.mkOrder 1000 (builtins.readFile ./src/zshrc.custom))
    ];

    shellAliases = {
      emacs = "emacsclient -c -a \"emacs\"";
      # Git shortcuts (curated subset of the oh-my-zsh git plugin, no omz).
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gapa = "git add --patch";
      gb = "git branch";
      gba = "git branch -a";
      gbd = "git branch -d";
      gbD = "git branch -D";
      gbl = "git blame -b -w";
      gc = "git commit -v";
      "gc!" = "git commit --amend";
      gca = "git commit -v -a";
      "gca!" = "git commit -v -a --amend";
      gcb = "git checkout -b";
      gcm = "git checkout \"$(git_main_branch)\"";
      gco = "git checkout";
      gd = "git diff";
      gdca = "git diff --cached";
      gdw = "git diff --word-diff";
      gf = "git fetch";
      gfa = "git fetch --all --prune";
      gfo = "git fetch origin";
      gl = "git pull";
      glg = "git log --stat";
      glgg = "git log --graph";
      glgga = "git log --graph --decorated --all";
      glo = "git log --oneline --decorate";
      glog = "git log --oneline --decorate --graph";
      gpsup = "git push --set-upstream origin \"$(git_current_branch)\"";
      gpf = "git push --force-with-lease";
      gpoat = "git push origin --all && git push origin --tags";
      gr = "git remote";
      grv = "git remote -v";
      gst = "git status";
      gss = "git status -s";
      gsta = "git stash";
      gstl = "git stash list";
      gstp = "git stash pop";
    };

  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  catppuccin.fzf.enable = true;

  home.file."${zshDir}/powerlevel10k".source = powerlevel10k;
  home.file."${zshDir}/zsh-vi-mode".source = pkgs.zsh-vi-mode;
  home.file."${zshDir}/.p10k.zsh".source = ./src/p10k.zsh;
}
