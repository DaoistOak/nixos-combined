# hyprwinwrap: display any window as a background/wallpaper in Hyprland.
# No flake upstream; build with cmake against the flake Hyprland dev output
# (hyprland.pc via pkg-config). Requires deps are resolved from hyprland's
# OWN git-pinned ecosystem (hyprland-packages overlay over the repo nixpkgs).
# Pinned to a72d3ee (v0.56.0 line in its hyprpm.toml; v0.56.1 is a patch on
# the same ABI line).
{ inputs, ... }:

let
  system = "x86_64-linux";
  hyprDev = inputs.hyprland.packages.${system}.hyprland;
  hyprPkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [ inputs.hyprland.overlays.hyprland-packages ];
  };
in
hyprPkgs.stdenv.mkDerivation {
  pname = "hyprwinwrap";
  version = "0.1.0";

  src = inputs.hyprwinwrap;

  nativeBuildInputs = [
    hyprPkgs.cmake
    hyprPkgs.pkg-config
  ];
  # hyprland.pc Requires: aquamarine, hyprcursor, hyprgraphics, hyprlang,
  # hyprutils, libdrm, egl, cairo, xkbcommon, libinput, wayland-server,
  # xcb, xcb-render, xcb-xfixes, xcb-icccm, xcb-composite, xcb-res, xcb-errors
  # Plus hyprwinwrap's own deps: pangocairo, pixman-1, libudev, lua5.5
  buildInputs = [
    hyprDev
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
    hyprPkgs.pango
    hyprPkgs.pixman
    hyprPkgs.lua5_5
    hyprPkgs.libxcb
    hyprPkgs.xcbutil
    hyprPkgs.xcbutilwm
    hyprPkgs.xcbutilimage
    hyprPkgs.xcbutilkeysyms
    hyprPkgs.xcbutilerrors
    hyprPkgs.systemdLibs
    hyprPkgs.glslang
  ];
  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];

  # hyprland.pc lives in the dev output's share/pkgconfig; point pkg-config at
  # it explicitly (buildInputs only surfaces the default out output otherwise).
  PKG_CONFIG_PATH = "${hyprDev.dev}/share/pkgconfig:${hyprDev.dev}/lib/pkgconfig";

  meta = {
    homepage = "https://github.com/gen3vra/hyprwinwrap";
    description = "Display any window as a background/wallpaper in Hyprland";
    platforms = hyprPkgs.lib.platforms.linux;
  };
}
