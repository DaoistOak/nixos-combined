{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  repoLockPath = "${config.home.homeDirectory}/.config/nixos/modules/home/config/modules/nvim/src/nvim/lazy-lock.json";
in
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

  # After the nvchad config is copied into place, headlessly update the lazy.nvim
  # plugins so a switch also upgrades Neovim plugins, then copy the freshly
  # rewritten lockfile back into the repo so `updt` commits the new pins.
  home.activation.updateNvimPlugins = lib.hm.dag.entryAfter [ "copyNvchadConfig" ] ''
    launcher=( "${lib.getExe config.programs.nvchad.finalPackage}" --headless "+Lazy! update" +qa )
    if PATH="${pkgs.gnumake}/bin:${pkgs.curl}/bin:${pkgs.python3}/bin:${pkgs.git}/bin:$PATH" \
      ''${launcher[@]} >/dev/null 2>&1; then
      if [ -f "${config.home.homeDirectory}/.config/nvim/lazy-lock.json" ]; then
        ${pkgs.coreutils}/bin/cp \
          "${config.home.homeDirectory}/.config/nvim/lazy-lock.json" \
          "${repoLockPath}"
      fi
    else
      echo "warning: nvim headless Lazy update failed; keeping existing pins"
    fi
  '';
}
