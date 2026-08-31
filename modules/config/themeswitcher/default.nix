{
  config,
  lib,
  ...
}:
{
  # Runtime theme switcher as a Quickshell fuzzy-finder, styled after the
  # Noctalia design language. Launched by Hyprland on startup (startup.nix) and
  # toggled with super+t (keybinds.nix) via:
  #   qs ipc -c themeswitcher call themeswitcher toggle
  #
  # The widget reads the same runtime state as scripts/theme (themes.json + the
  # Noctalia palette) so it always reflects the current theme and hot-swaps on
  # every selection through the CLI: /home/zeph/.config/nixos/scripts/theme.
  config = {
    xdg.configFile = {
      "quickshell/themeswitcher/shell.qml" = {
        source = ./shell.qml;
        force = true;
      };
      "quickshell/themeswitcher/qmldir" = {
        source = ./qmldir;
        force = true;
      };
      "quickshell/themeswitcher/ThemePalette.qml" = {
        source = ./ThemePalette.qml;
        force = true;
      };
      "quickshell/themeswitcher/ThemeDb.qml" = {
        source = ./ThemeDb.qml;
        force = true;
      };
      "quickshell/themeswitcher/ThemeSwitcher.qml" = {
        source = ./ThemeSwitcher.qml;
        force = true;
      };
      "quickshell/themeswitcher/ListRow.qml" = {
        source = ./ListRow.qml;
        force = true;
      };
    };
  };
}
