{
  config,
  lib,
  pkgs,
  ...
}:
let
  zshDir = "${config.xdg.configHome}/zsh";
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = zshDir;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "vi-mode"
      ];
      theme = "robbyrussell";
    };

    initContent = lib.mkOrder 1000 (builtins.readFile ./src/zshrc.custom);
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  catppuccin.fzf.enable = true;
}
