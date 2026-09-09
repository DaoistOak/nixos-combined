{ pkgs, inputs, ... }:

let
  home-pkgs = (import ../../../../pkgs/pkgs.nix { inherit pkgs inputs; }).home-pkgs;
in
{
  home.packages = home-pkgs;
}
