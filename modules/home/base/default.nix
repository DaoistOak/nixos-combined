{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  themeMod = import ../config/themes/colors/themes.nix { inherit lib; };
  themeSel = themeMod.readSelection ../config/themes/colors/src/selection;
  catppuccinAccent =
    if themeMod.themes.catppuccin.flavors.macchiato.accents ? ${themeSel.accentName} then
      themeSel.accentName
    else
      "mauve";
in
{
  imports = [
    ../config/modules/hypr/hyprland
    ../config/modules/hypr/hypridle
    ../config/modules/hypr/hyprlock
    ../config/modules/herdr
    ../config/modules/crush
    ../config/cava
    ../config/modules/yazi
    ../config/modules/superfile
    ../config/modules/kitty
    ../config/modules/alacritty
    ../config/modules/wezterm
    ../config/modules/tmux
    ../config/modules/phone-bt-bridge
    ../config/themes/colors
    ../config/themes/themer
    ../config/themes/theme
    ../config/modules/zsh
    ../config/pkgs
    inputs.noctalia.homeModules.default
  ];

  home.username = "zeph";
  home.homeDirectory = "/home/zeph";
  gtk.enable = true;
  stylix.targets.gtk.extraCss = ''
    @import url("noctalia.css");
  '';
  qt.enable = true;
  home.stateVersion = "26.05";
  home.pointerCursor.enable = true;
  wayland.windowManager.hyprland.configType = "lua";

  catppuccin = {
    enable = themeSel.themeName == "catppuccin";
    autoEnable = true;
    flavor =
      if builtins.hasAttr themeSel.flavorName themeMod.themes.catppuccin.flavors then
        themeSel.flavorName
      else
        "macchiato";
    accent = catppuccinAccent;
    kitty.enable = false;
    alacritty.enable = false;
    wezterm.enable = false;
    tmux.enable = false;
  };

  xdg.configFile."gtk-3.0/gtk.css".force = true;
  xdg.configFile."hypr/hyprlock.conf".force = true;
  xdg.configFile."gtk-4.0/gtk.css".force = true;
  xdg.configFile."mimeapps.list".force = true;

  # stylix writes ~/.local/share/flatpak/overrides/global for flatpak theming;
  # a real file already exists there (Wayland/sockets+DRI override), so merge
  # both into the managed file instead of clobbering it.
  xdg.dataFile."flatpak/overrides/global".text = lib.mkForce ''
    [Context]
    sockets=inherit-wayland-socket;system-bus;session-bus;wayland
    devices=all;dri
    features=per-app-dev-shm;bluetooth
    filesystems=${config.home.homeDirectory}/.themes/adw-gtk3:ro

    [Environment]
    GTK_THEME=adw-gtk3
  '';
  xdg.dataFile."flatpak/overrides/global".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.kde.dolphin.desktop";
      "application/pdf" = "org.kde.okular.desktop";
    };
  };

  programs.noctalia = {
    enable = true;
    package = (inputs.noctalia.packages.${pkgs.system}.default).overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ../noctalia-shadow-offset-blur.patch ];
    });
    settings.theme = lib.mkForce {
      source = "custom";
      custom_palette = "themeswapper";
      mode = if themeSel.r.polarity == "light" then "light" else "dark";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "wezterm start";
    QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
    QT_STYLE_OVERRIDE = lib.mkForce "kvantum";
    FLAKE_DIR = "/home/zeph/.config/nixos";
  };

  xdg.configFile.".gtkrc-2.0" = {
    force = true;
    text = "# Default GTK RC-2.0 Configuration\n";
  };

  xresources.path = "${config.xdg.configHome}/X11/xresources";
  home.pointerCursor.dotIcons.enable = false;

  programs.home-manager.enable = true;

  programs.devenv = {
    enable = true;
    enableZshIntegration = true;
  };

  systemd.user.startServices = true;
  home.file.".config/wget/wgetrc" = {
    text = ''
      hsts-file = ${config.home.homeDirectory}/.local/share/wget-hsts
    '';
  };
}
