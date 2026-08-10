# hypr-edgehover: forward edge-gap pointer motion to adjacent Hyprland windows
# No flake upstream; build with cmake against the flake Hyprland (dev output).
{ inputs, ... }:

let
  hyprPkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    overlays = [ inputs.hyprland.overlays.hyprland-packages ];
  };
  # glaze: hyprland v0.55.4's start/ subproject fetch-depends glaze via
  # FetchContent (git + network, blocked by the nix sandbox). hyprland's own
  # pinned nixpkgs ships glaze 7.7.1, satisfying find_package(glaze 7...<8).
  hyprland = hyprPkgs.hyprland.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ hyprPkgs.git ];
    buildInputs = old.buildInputs ++ [
      inputs.hyprland.inputs.nixpkgs.legacyPackages.x86_64-linux.glaze
    ];
  });
in
hyprPkgs.stdenv.mkDerivation {
  pname = "hypr-edgehover";
  version = "0.1.0";

  src = inputs.hypr-edgehover;

  nativeBuildInputs = [
    hyprPkgs.cmake
    hyprPkgs.pkg-config
  ];
  buildInputs = [
    hyprland
    hyprPkgs.aquamarine
    hyprPkgs.hyprcursor
    hyprPkgs.hyprgraphics
    hyprPkgs.hyprlang
    hyprPkgs.hyprutils
    hyprPkgs.libdrm
    hyprPkgs.libGL
    hyprPkgs.cairo
    hyprPkgs.libxkbcommon
    hyprPkgs.libinput
    hyprPkgs.wayland
    hyprPkgs.libxcb
    hyprPkgs.xcbutil
    hyprPkgs.xcbutilwm
    hyprPkgs.xcbutilimage
    hyprPkgs.xcbutilkeysyms
    hyprPkgs.xcbutilerrors
    hyprPkgs.pixman
    hyprPkgs.glm
  ];
  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    homepage = "https://github.com/gfhdhytghd/hypr-edgehover";
    description = "Forward edge-gap pointer motion to adjacent Hyprland windows";
    platforms = hyprPkgs.lib.platforms.linux;
  };
}
