# hypr-edgehover: forward edge-gap pointer motion to adjacent Hyprland windows.
# No flake upstream; build with cmake against the flake Hyprland dev output
# (headers + hyprland.pc via pkg-config). Its Requires deps are resolved from
# hyprland's OWN git-pinned ecosystem (hyprland-packages overlay over the repo
# nixpkgs), so the versions match the running binary exactly (e.g. aquamarine
# 0.13.0+date). The hyprland package itself is the already-cached flake build —
# never rebuild it.
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
  pname = "hypr-edgehover";
  version = "0.1.0";

  src = inputs.hypr-edgehover;

  nativeBuildInputs = [
    hyprPkgs.cmake
    hyprPkgs.pkg-config
  ];
  # hyprland.pc Requires: aquamarine, hyprcursor, hyprgraphics, hyprlang,
  # hyprutils, libdrm, egl, cairo, xkbcommon, libinput, wayland-server,
  # xcb, xcb-render, xcb-xfixes, xcb-icccm, xcb-composite, xcb-res, xcb-errors
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
    hyprPkgs.libxcb
    hyprPkgs.xcbutil
    hyprPkgs.xcbutilwm
    hyprPkgs.xcbutilimage
    hyprPkgs.xcbutilkeysyms
    hyprPkgs.xcbutilerrors
  ];
  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  # hyprland.pc lives in the dev output's share/pkgconfig; point pkg-config at
  # it explicitly (buildInputs only surfaces the default out output otherwise).
  PKG_CONFIG_PATH = "${hyprDev.dev}/share/pkgconfig:${hyprDev.dev}/lib/pkgconfig";

  meta = {
    homepage = "https://github.com/gfhdhytghd/hypr-edgehover";
    description = "Forward edge-gap pointer motion to adjacent Hyprland windows";
    platforms = hyprPkgs.lib.platforms.linux;
  };
}
