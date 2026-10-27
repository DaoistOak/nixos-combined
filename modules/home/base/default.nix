{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  themeMod = import ../config/themes/colors/_themes.nix { inherit lib; };
  themeSel = themeMod.readSelection ../config/themes/colors/src/selection;
  catppuccinAccent =
    if themeMod.themes.catppuccin.flavors.macchiato.accents ? ${themeSel.accentName} then
      themeSel.accentName
    else
      "mauve";
in
{
  # Every .nix under modules/home is auto-discovered by import-tree (wired in
  # modules/system/hosts/_Lingnao.nix), so app modules must NOT be listed here.
  # Only modules that live outside that tree are listed: flake inputs.
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home.username = config.var.username;
  home.homeDirectory = "/home/${config.var.username}";
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
    ghostty.enable = false;
    tmux.enable = false;
    # nvim is themed from the tracked selection too, but through the base16
    # palette in lua/theme.lua (so `theme set` can recolor it live) instead of
    # a generated `colorscheme catppuccin` line in init.lua.
    nvim.enable = false;
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
  # No mimeapps.list in the XDG lookup path declares a default for http, and
  # six browsers all register x-scheme-handler/http (brave, chromium, brave's
  # app-id variant, firefox, qutebrowser, zen). With nothing declared, the
  # default falls through to the MIME cache built from the desktop files, which
  # handed it to brave-browser.desktop at random -- so links opened in Brave
  # while xdg-settings and BROWSER both said firefox. Declaring it here makes
  # the choice explicit and stops it drifting again after a rebuild.
  # Keep this in sync with `BROWSER` below: xdg-settings honours $BROWSER ahead
  # of this list, so a stale BROWSER silently wins and the declared default
  # stops being what anything actually reports.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.kde.dolphin.desktop";
      "application/pdf" = "org.kde.okular.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "text/html" = "zen.desktop";
    };
  };

  programs.noctalia = {
    enable = true;
    # Default noctalia package (stale shadow-offset-blur patch backed up to
    # .bak); patch no longer applied.
    package = (inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default);
    settings.theme = lib.mkForce {
      source = "custom";
      custom_palette = "themeswapper";
      mode = if themeSel.r.polarity == "light" then "light" else "dark";
    };
    # This lived only in a stale `noctalia config export` dump that sat in
    # ~/.config/noctalia/ (Noctalia merges every *.toml in that dir, so the
    # dump was silently overriding the managed config). Declared here instead.
    settings.audio.enable_sounds = false;
  };

  home.sessionVariables = {
    BROWSER = "zen";
    TERMINAL = "ghostty";
    # Plasma/KDE QML apps (krunner, systemsettings, the wallpaper KCM, …)
    # resolve their QtQuick Controls style through the platform theme. Forcing
    # qt6ct here made them read qt6ct's kvantum widget style and fail with
    # `module "kvantum" is not installed`, crashing every Kirigami app.
    # plasma-integration's "kde" theme is the correct choice in a Plasma
    # session and still honours kdeglobals/Qt_STYLE_OVERRIDE on Hyprland.
    QT_QPA_PLATFORMTHEME = lib.mkForce "kde";
    QT_STYLE_OVERRIDE = lib.mkForce "kvantum";
    FLAKE_DIR = config.var.configDirectory;
  };

  # The Qt home-manager module derives QT_QPA_PLATFORMTHEME from
  # `qt.platformTheme.name` (stylix pins it to `qtct` → `qt5ct`) and emits it
  # into systemd.user.sessionVariables, which is the environment Plasma's
  # systemd-activated apps (plasma-krunner.service, app-systemsettings@…,
  # the wallpaper KCM, …) actually inherit. Override it here as well, otherwise
  # those units keep the broken qt5ct theme even though the shell env is fixed.
  systemd.user.sessionVariables.QT_QPA_PLATFORMTHEME = lib.mkForce "kde";

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
