{
  config,
  pkgs,
  lib,
  ...
}:

{
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
      "tty"
      "input"
    ];
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };

  # SDDM's greeter (and the pixie-sddm avatar) runs as the `sddm` user and reads
  # the profile picture from ~/.face; the file + home-dir perms are deployed by
  # the sddm module's activation script.

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    ZDOTDIR = "/home/zeph/.config/zsh";
    XDG_CONFIG_HOME = "/home/zeph/.config";
    XDG_DATA_HOME = "/home/zeph/.local/share";
    XDG_CACHE_HOME = "/home/zeph/.cache";
    XDG_STATE_HOME = "/home/zeph/.local/state";
    ANDROID_USER_HOME = "/home/zeph/.local/share/android";
    CARGO_HOME = "/home/zeph/.local/share/cargo";
    GTK2_RC_FILES = "/home/zeph/.config/gtk-2.0/gtkrc";
    JULIA_DEPOT_PATH = "/home/zeph/.local/share/julia:$JULIA_DEPOT_PATH";
    NPM_CONFIG_INIT_MODULE = "/home/zeph/.config/npm/config/npm-init.js";
    NPM_CONFIG_CACHE = "/home/zeph/.cache/npm";
    NPM_CONFIG_TMP = "/run/user/1000/npm";
    PSQL_HISTORY = "/home/zeph/.local/state/psql_history";
    WAKATIME_HOME = "/home/zeph/.config/wakatime";
    WINEPREFIX = "/home/zeph/.local/share/wine";
    XCOMPOSECACHE = "/home/zeph/.cache/X11/xcompose";
    PYTHONSTARTUP = "/home/zeph/python/pythonrc";
    GRADLE_USER_HOME = "/home/zeph/.local/share/gradle";
    CODEX_HOME = "/home/zeph/.config/codex";
    DOTNET_CLI_HOME = "/home/zeph/.local/share/dotnet";
    CLAUDE_CONFIG_DIR = "/home/zeph/.config/claude";
    HERMES_HOME = "/home/zeph/.local/share/hermes";
    HISTFILE = "/home/zeph/.local/state/bash/history";
    SCREENDIR = "/run/user/1000/screen";
    PLATFORMIO_CORE_DIR = "/home/zeph/.local/share/platformio";
    SCIHOME = "/home/zeph/.local/state/scilab";
    PYTHON_HISTORY = "/home/zeph/.local/state/python_history";
    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=/home/zeph/.config/java";
    WGETRC = "/home/zeph/.config/wget/wgetrc";
  };
  programs.zsh.enable = true;
  programs.direnv.enableZshIntegration = true;

}
