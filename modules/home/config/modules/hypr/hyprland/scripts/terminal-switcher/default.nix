{
  config,
  lib,
  ...
}:
{
  xdg.configFile = {
    "quickshell/terminal-switcher/shell.qml" = {
      source = ./src/shell.qml;
      force = true;
    };
    "quickshell/terminal-switcher/qmldir" = {
      source = ./src/qmldir;
      force = true;
    };
    "quickshell/terminal-switcher/TermDb.qml" = {
      source = ./src/TermDb.qml;
      force = true;
    };
    "quickshell/terminal-switcher/TerminalSwitcher.qml" = {
      source = ./src/TerminalSwitcher.qml;
      force = true;
    };
    "quickshell/terminal-switcher/ListRow.qml" = {
      source = ./src/ListRow.qml;
      force = true;
    };
    "quickshell/terminal-switcher/ThemePalette.qml" = {
      source = ./src/ThemePalette.qml;
      force = true;
    };
  };
}
