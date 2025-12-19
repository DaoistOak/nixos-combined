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

  chaotic = {
    mesa-git.enable = true;
    nyx = {
      cache.enable = true;
      overlay.enable = true;
      nixPath.enable = true;
    };
  };

  programs.steam.enable = true;
  programs.hyprland.enable = true;
}
