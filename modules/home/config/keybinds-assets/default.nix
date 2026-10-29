{ config, pkgs, lib, ... }:
let
  modeFiles = [
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/global/binding/focus.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/global/binding/mouse.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/global/binding/window-move.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/global/binding/resize.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/global/binding/workspace.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/global/gestures.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/global/keys.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/terminal-apps.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/apps-bin.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/apps-bin/apps-vm.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/apps-bin/apps-editor.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/apps-bin/apps-file-open.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/apps-bin/apps-games.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/apps-bin/apps-media.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/messaging/messaging.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/messaging/messaging-viber.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/messaging/messaging-whatsapp.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/shell/shell.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/shell/shell-bluetooth.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/shell/shell-network.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/shell/shell-widgets.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/windows/windows.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/launch/file-manager.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/launch/web-browser.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/mode/launch/ai.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/special/keys.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/special/tools.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/special/launcher.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/special/system.nix
    /home/zeph/.config/nixos/modules/home/config/modules/hypr/hyprland/settings/keybinds/special/passthrough.nix
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
