{ config, pkgs, lib, ... }:
let
  modeFiles = [
      ../keybinds/global/binding/focus.nix
      ../keybinds/global/binding/mouse.nix
      ../keybinds/global/binding/window-move.nix
      ../keybinds/global/binding/resize.nix
      ../keybinds/global/binding/workspace.nix
      ../keybinds/global/gestures.nix
      ../keybinds/global/keys.nix
      ../keybinds/mode/terminal-apps.nix
      ../keybinds/mode/apps-bin.nix
      ../keybinds/mode/apps-bin/apps-vm.nix
      ../keybinds/mode/apps-bin/apps-editor.nix
      ../keybinds/mode/apps-bin/apps-file-open.nix
      ../keybinds/mode/apps-bin/apps-games.nix
      ../keybinds/mode/apps-bin/apps-media.nix
      ../keybinds/mode/messaging/messaging.nix
      ../keybinds/mode/messaging/messaging-viber.nix
      ../keybinds/mode/messaging/messaging-whatsapp.nix
      ../keybinds/mode/shell/shell.nix
      ../keybinds/mode/shell/shell-bluetooth.nix
      ../keybinds/mode/shell/shell-network.nix
      ../keybinds/mode/shell/shell-widgets.nix
      ../keybinds/mode/windows/windows.nix
      ../keybinds/mode/launch/file-manager.nix
      ../keybinds/mode/launch/web-browser.nix
      ../keybinds/mode/launch/ai.nix
      ../keybinds/special/keys.nix
      ../keybinds/special/tools.nix
      ../keybinds/special/launcher.nix
      ../keybinds/special/system.nix
      ../keybinds/special/passthrough.nix
  ];
  importedModules = map (m: import m) modeFiles;
  moduleResults =
    map (m: m { config = config; pkgs = pkgs; }) importedModules;
  allConfigs =
    lib.concatStringsSep "\n" (
      map (m: m.wayland.windowManager.hyprland.extraConfig) moduleResults
    );
in
{ wayland.windowManager.hyprland.extraConfig = '';${allConfigs}''; }
