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

  # FHS compat for pressure-vessel (Proton's container runtime)
  systemd.tmpfiles.rules = [
    "L+ /usr/bin/true - - - - ${pkgs.coreutils}/bin/true"
    "d /var/cache/ldconfig 0755 root root -"
    "w /var/cache/ldconfig/ld.so.cache 0644 root root - glibc-ld.so.cache1.1"
  ];
}
