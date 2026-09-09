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

  home.file."${zshDir}/powerlevel10k".source = powerlevel10k;
  home.file."${zshDir}/.p10k.zsh".source = ./src/p10k.zsh;
}
