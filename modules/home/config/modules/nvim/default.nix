{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.nvnix.homeManagerModules.nvnix ];

  programs.nvchad = {
    enable = true;
    package = pkgs.neovim;
    starterConfig = ./src/nvim;
    lazyLock = ./src/nvim/lazy-lock.json;
    backup = false;
    desktopEntry.enable = false;
  };

  home.packages = lib.mkDefault [
    pkgs.stylua
    pkgs.lua-language-server
  ];
}
