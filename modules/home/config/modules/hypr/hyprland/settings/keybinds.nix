{ config, pkgs, lib, ... }:
let
  segmentFiles = [
    ./_keybinds/modules.nix
    ./_keybinds/global/binding/snippet.nix
    ./_keybinds/global/binding/focus.nix
    ./_keybinds/global/binding/mouse.nix
    ./_keybinds/global/binding/window-move.nix
    ./_keybinds/global/binding/resize.nix
    ./_keybinds/global/binding/workspace.nix
    ./_keybinds/global/modes.nix
    ./_keybinds/global/transparency.nix
    ./_keybinds/global/gestures.nix
    ./_keybinds/global/keys.nix
    ./_keybinds/mode/terminal-apps.nix
    ./_keybinds/mode/apps-bin.nix
    ./_keybinds/mode/apps-bin/apps-vm.nix
    ./_keybinds/mode/apps-bin/apps-editor.nix
    ./_keybinds/mode/apps-bin/apps-file-open.nix
    ./_keybinds/mode/apps-bin/apps-games.nix
    ./_keybinds/mode/apps-bin/apps-media.nix
    ./_keybinds/mode/messaging/messaging.nix
    ./_keybinds/mode/messaging/messaging-viber.nix
    ./_keybinds/mode/messaging/messaging-whatsapp.nix
    ./_keybinds/mode/shell/shell.nix
    ./_keybinds/mode/shell/shell-bluetooth.nix
    ./_keybinds/mode/shell/shell-network.nix
    ./_keybinds/mode/shell/shell-widgets.nix
    ./_keybinds/mode/windows/windows.nix
    ./_keybinds/mode/launch/file-manager.nix
    ./_keybinds/mode/launch/web-browser.nix
    ./_keybinds/mode/launch/ai.nix
    ./_keybinds/special/keys.nix
    ./_keybinds/special/tools.nix
    ./_keybinds/special/launcher.nix
    ./_keybinds/special/system.nix
    ./_keybinds/special/passthrough.nix
  ];
  importedModules = map (m: import m) segmentFiles;
  moduleResults = map (m: m { config = config; pkgs = pkgs; lib = lib; }) importedModules;
  allConfigs = lib.concatStringsSep "\n" (map (m: m.wayland.windowManager.hyprland.extraConfig) moduleResults);
in
{ wayland.windowManager.hyprland.extraConfig = allConfigs; }