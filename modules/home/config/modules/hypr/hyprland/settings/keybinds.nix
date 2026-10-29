{ config, pkgs, lib, ... }:
let
  keybindsAssets = import /home/zeph/.config/nixos/modules/home/config/keybinds-assets;
in
keybindsAssets { inherit config pkgs lib; }
