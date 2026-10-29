{ config, pkgs, lib, ... }:
let
  keybindsAssets = import ./keybinds-assets;
in
keybindsAssets { inherit config pkgs lib; }
