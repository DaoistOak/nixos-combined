{
  config,
  lib,
  ...
}:
{
  config = {
    xdg.configFile = {
      "quickshell/themeswitcher/shell.qml" = {
        source = ./src/shell.qml;
        force = true;
      };
      "quickshell/themeswitcher/qmldir" = {
        source = ./src/qmldir;
        force = true;
      };
      "quickshell/themeswitcher/ThemePalette.qml" = {
        source = ./src/ThemePalette.qml;
        force = true;
      };
      "quickshell/themeswitcher/ThemeDb.qml" = {
        source = ./src/ThemeDb.qml;
        force = true;
      };
      "quickshell/themeswitcher/ThemeSwitcher.qml" = {
        source = ./src/ThemeSwitcher.qml;
        force = true;
      };
      "quickshell/themeswitcher/ListRow.qml" = {
        source = ./src/ListRow.qml;
        force = true;
      };
    };
  };
}
