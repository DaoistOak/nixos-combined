{ pkgs, inputs, ... }:

let
  system-pkgs = (import ../../../../pkgs/pkgs.nix { inherit pkgs inputs; }).system-pkgs;
in
{
  environment.systemPackages = system-pkgs;

  services.flatpak.enable = true;

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      liberation_ttf
      dejavu_fonts
    ];
  };

  environment.ldso32 = "${pkgs.pkgsi686Linux.glibc}/lib/ld-linux.so.2";
}
