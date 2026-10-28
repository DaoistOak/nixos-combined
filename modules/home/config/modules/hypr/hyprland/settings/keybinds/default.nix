{ config, pkgs, lib, ... }:
let
  modules = [
    ./modules.nix
    ./global/keys.nix
    ./global/binding/mouse.nix
    ./global/gestures.nix
    ./global/binding/workspace.nix
    ./global/binding/focus.nix
    ./global/binding/window-move.nix
    ./global/binding/resize.nix
    ./mode/terminal-apps.nix
    ./mode/shell/shell.nix
    ./mode/shell/shell-bluetooth.nix
    ./mode/shell/shell-network.nix
    ./mode/shell/shell-widgets.nix
    ./mode/messaging/messaging.nix
    ./mode/messaging/messaging-viber.nix
    ./mode/messaging/messaging-whatsapp.nix
    ./mode/windows/windows.nix
    ./mode/launch/file-manager.nix
    ./mode/launch/web-browser.nix
    ./mode/launch/ai.nix
    ./mode/apps-bin.nix
    ./mode/apps-bin/apps-vm.nix
    ./mode/apps-bin/apps-editor.nix
    ./mode/apps-bin/apps-file-open.nix
    ./mode/apps-bin/apps-media.nix
    ./mode/apps-bin/apps-games.nix
    ./special/keys.nix
    ./special/tools.nix
    ./special/launcher.nix
    ./special/system.nix
    ./special/passthrough.nix
  ];

  allConfigs =
    lib.concatStringsSep "\n" (
      map (m: (m { config, pkgs, lib, ... }).wayland.windowManager.hyprland.extraConfig) modules
    );
in {
  wayland.windowManager.hyprland.extraConfig = '';
    ${allConfigs}
  '';
}
