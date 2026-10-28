{ config, pkgs, lib, ... }:
let
  keybindsModule =
    import ./keybinds { inherit config pkgs lib; };
in
keybindsModule
