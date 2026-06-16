{ pkgs, inputs, ... }:

let
  system-packages = (import ../pkgs/default.nix { inherit pkgs inputs; }).system-packages;
in
{
  # Nixpkgs settings
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
  };

  environment.systemPackages = system-packages;

  services.flatpak.enable = true;
  users.extraGroups.docker.members = [ "zeph" ];

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      liberation_ttf
      dejavu_fonts
    ];
  };

  programs.steam.enable = true;
  programs.hyprland.enable = true;

  # Kept for future: 32-bit ld-linux at FHS path, may be needed if running GE-Proton/
  # pressure-vessel outside Lutris' buildFHSEnv sandbox (nix-ld removes it otherwise)
  environment.ldso32 = "${pkgs.pkgsi686Linux.glibc}/lib/ld-linux.so.2";
}
