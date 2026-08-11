{ pkgs, inputs, ... }:

let
  system-packages = (import ../pkgs/default.nix { inherit pkgs inputs; }).system-packages;
in
{
  environment.systemPackages = system-packages;

  services.flatpak.enable = true;

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      liberation_ttf
      dejavu_fonts
    ];
  };

  # Kept for future: 32-bit ld-linux at FHS path, may be needed if running GE-Proton/
  # pressure-vessel outside Lutris' buildFHSEnv sandbox (nix-ld removes it otherwise)
  environment.ldso32 = "${pkgs.pkgsi686Linux.glibc}/lib/ld-linux.so.2";
}
