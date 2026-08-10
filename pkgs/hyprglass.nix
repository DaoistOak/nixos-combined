# hyprglass: Liquid-Glass effects plugin for Hyprland
# No flake upstream; build with its Makefile against the flake Hyprland (dev output).
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
  pname = "hyprglass";
  version = "unstable-2026-08-10";

  src = inputs.hyprglass;

  nativeBuildInputs = [ hyprPkgs.pkg-config ];
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
    hyprPkgs.glslang
    hyprPkgs.lua
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 hyprglass.so "$out/lib/hyprglass.so"
    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/hyprnux/hyprglass";
    description = "Hyprland plugin adding blur, refraction and glass effects to transparent windows";
    platforms = hyprPkgs.lib.platforms.linux;
  };
}
