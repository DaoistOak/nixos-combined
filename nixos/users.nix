{ config, pkgs, ... }:

{
  # Define user accounts
  users.users.zeph = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "SD";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "libvirtd"
      "kvm"
      "qemu-libvirtd"
      "nixos"
      "dialout"
      "video"
      "render"
      "seat"
      "docker"
    ];
  };

  # User-specific environment variables
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    ZDOTDIR = "/home/zeph/.config/zsh";
    XDG_CONFIG_HOME = "/home/zeph/.config";
    XDG_DATA_HOME = "/home/zeph/.local/share";
    XDG_CACHE_HOME = "/home/zeph/.cache";
  };
  environment.sessionVariables = {
  };
  # Enable Zsh
  programs.zsh.enable = true;
  programs.direnv.enableZshIntegration = true;

}
