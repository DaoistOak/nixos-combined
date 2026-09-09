{
  config,
  pkgs,
  lib,
  ...
}:

let
  themeMod = import ../../../home/config/themes/colors/themes.nix { inherit lib; };
  themeSel = themeMod.readSelection ../../../home/config/themes/colors/src/selection;
in
{
  stylix = {
    enable = true;
    base16Scheme = themeMod.toBase16 themeSel.r;
    image = null;
    targets.console.enable = true;
    targets.plymouth.enable = true;
    targets.gtksourceview.enable = false;
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnsupportedSystem = true;
    allowAliases = false;
    permittedInsecurePackages = [
      "electron-40.10.5"
      "pnpm-10.29.2"
    ];
  };

  environment.systemPackages = with pkgs; [
    base16-schemes
  ];

  console.font = "/run/current-system/sw/share/consolefonts/ter-u18n.psf.gz";

  programs.xwayland.enable = true;
  programs.xwayland.package = pkgs.xwayland;

  programs.nix-ld = {
    enable = true;
    libraries =
      with pkgs;
      [
        libtheora
        speex
        libgudev
        libvdpau
      ]
      ++ (with pkgs.pkgsi686Linux; [
        libtheora
        speex
        libgudev
        libvdpau
      ]);
  };

  system.stateVersion = "26.05";
}
