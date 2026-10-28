{ config, pkgs, lib, ... }:
{
  # Keybinds for Hyprland. The Lua config is built from the segment assets
  # below (settings/_keybinds/*.lua), each authored as a logical chunk of the
  # Hyprland Lua config (mouse binds, global binds, modes, workspaces, media,
  # terminal-apps/shell submaps, apps submaps, messaging, windows). The
  # segments are *.lua assets under _keybinds/ (import-tree skips _-prefixed
  # and non-.nix files), so this file is the only module that sets
  # wayland.windowManager.hyprland.extraConfig -> no duplicate-module conflict.
  wayland.windowManager.hyprland.extraConfig =
    lib.concatStringsSep "\n"
    (
      let
        _segs =
          [
            (builtins.readFile ./_keybinds/APPS__SUPER_E.lua)
                      (builtins.readFile ./_keybinds/APPS___AI_ASSISTANTS__SUPER_E__A.lua)
                      (builtins.readFile ./_keybinds/APPS___EDITORS__SUPER_E__E.lua)
                      (builtins.readFile ./_keybinds/APPS___FILES__SUPER_E__F.lua)
                      (builtins.readFile ./_keybinds/APPS___FILES___OPEN__SUPER_E__F__C.lua)
                      (builtins.readFile ./_keybinds/APPS___GAMES__SUPER_E__G.lua)
                      (builtins.readFile ./_keybinds/APPS___MEDIA__SUPER_E__M.lua)
                      (builtins.readFile ./_keybinds/APPS___VM__SUPER_E__V.lua)
                      (builtins.readFile ./_keybinds/APPS___WEB__SUPER_E__W.lua)
                      (builtins.readFile ./_keybinds/FOCUS__SUPER.lua)
                      (builtins.readFile ./_keybinds/GLOBAL__SUPER.lua)
                      (builtins.readFile ./_keybinds/LAUNCHER__SUPER_TAP.lua)
                      (builtins.readFile ./_keybinds/MEDIA___HARDWARE_KEYS.lua)
                      (builtins.readFile ./_keybinds/MESSAGING__SUPER_M.lua)
                      (builtins.readFile ./_keybinds/MESSAGING___VIBER__SUPER_M__V.lua)
                      (builtins.readFile ./_keybinds/MESSAGING___WHATSAPP__SUPER_M__W.lua)
                      (builtins.readFile ./_keybinds/MODES__SUPER.lua)
                      (builtins.readFile ./_keybinds/MOUSE__SUPER_HELD.lua)
                      (builtins.readFile ./_keybinds/PASSTHROUGH__SUPER_SHIFT_ESC.lua)
                      (builtins.readFile ./_keybinds/RESIZE__SUPER_CTRL.lua)
                      (builtins.readFile ./_keybinds/SHELL__SUPER_S.lua)
                      (builtins.readFile ./_keybinds/SHELL___BLUETOOTH__SUPER_S__B.lua)
                      (builtins.readFile ./_keybinds/SHELL___NETWORK__SUPER_S__N.lua)
                      (builtins.readFile ./_keybinds/SHELL___WIDGETS__SUPER_S__D____DESKTOP_WIDGET_TOGGLES.lua)
                      (builtins.readFile ./_keybinds/SYSTEM__SUPER.lua)
                      (builtins.readFile ./_keybinds/TERMINAL_APPS__SUPER_T.lua)
                      (builtins.readFile ./_keybinds/TOOLS__SUPER.lua)
                      (builtins.readFile ./_keybinds/WINDOWS__SUPER_W.lua)
                      (builtins.readFile ./_keybinds/WINDOW_MOVE__SUPER.lua)
                      (builtins.readFile ./_keybinds/WORKSPACES__SUPER.lua)

          ]
      ; in
      map (s: s) _segs
    );
}
