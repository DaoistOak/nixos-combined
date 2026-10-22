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
      jetbrains-mono
      # The SDDM greeter runs as the `sddm` user and only sees system fonts, so
      # the Nerd Font that draws the theme's session icons (U+F07C0) has to be
      # installed here rather than in ~/.local/share/fonts.
      nerd-fonts.jetbrains-mono
    ];
  };

  environment.ldso32 = "${pkgs.pkgsi686Linux.glibc}/lib/ld-linux.so.2";
}
