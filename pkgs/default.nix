# PACKAGES MANIFEST - Single source of truth for all packages.
# Edit `system-packages.nix` (NixOS/system-wide) and `user-packages.nix` (home-manager/user).
# Keep home and system packages intentionally separated.
# You can build them using 'nix build .#example'
{ pkgs, inputs, ... }:

let
  # Patch nix-search-tv to always exec zsh instead of resolving $SHELL.
  ns = pkgs.writeShellApplication {
    name = "ns";
    runtimeInputs = with pkgs; [
      fzf
      nix-search-tv
    ];
    text =
      builtins.replaceStrings
        [
          "nix-shell --run $SHELL -p "
        ]
        [
          "nix-shell --run zsh -p zsh "
        ]
        (builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh");
  };

  nix-add = pkgs.writeShellApplication {
    name = "nix-add";
    runtimeInputs = with pkgs; [
      fzf
      nix-search-tv
      nixfmt
      git
      jq
      python3
    ];
    text = builtins.readFile ../scripts/nix-add;
  };

  user-packages-list = (import ./user-packages.nix { inherit pkgs inputs; }) ++ [ ns nix-add ];
  system-packages-list = import ./system-packages.nix { inherit pkgs inputs; };
in
{
  user-packages = user-packages-list;
  system-packages = system-packages-list;
}
