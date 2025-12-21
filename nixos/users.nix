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
    XDG_STATE_HOME = "/home/zeph/.local/state";
    ANDROID_USER_HOME = "$XDG_DATA_HOME/android";
    CARGO_HOME = "$XDG_DATA_HOME/cargo";
    GTK2_RC_FILES = "$XDG_CONFIG_HOME/gtk-2.0/gtkrc";
    JULIA_DEPOT_PATH = "$XDG_DATA_HOME/julia:$JULIA_DEPOT_PATH";
    NPM_CONFIG_INIT_MODULE = "$XDG_CONFIG_HOME/npm/config/npm-init.js";
    NPM_CONFIG_CACHE = "$XDG_CACHE_HOME/npm";
    NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
    PSQL_HISTORY = "$XDG_STATE_HOME/psql_history";
    SCIHOME = "$XDG_STATE_HOME/scilab";
    WAKATIME_HOME = "$XDG_CONFIG_HOME/wakatime";
    WINEPREFIX = "$XDG_DATA_HOME/wine";
    XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";
    NIX_LD_LIBRARY_PATH = "$(nix eval --raw nixpkgs#glibc.outPath)/lib";
    XCOMPOSECACHE = "$XDG_CACHE_HOME/X11/xcompose";
    PYTHONSTARTUP = "/home/zeph/python/pythonrc";
  };
  environment.sessionVariables = {
  };
  # Enable Zsh
  programs.zsh.enable = true;
  programs.direnv.enableZshIntegration = true;

}
