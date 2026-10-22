{
  config,
  inputs,
  pkgs,
  ...
}:
{
  # settings/*.nix and scripts/*.nix are auto-discovered by import-tree (see
  # modules/system/hosts/_Lingnao.nix) -- they must NOT be listed here.
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    # stdenv override: the flake's pinned nixpkgs is glibc 2.42 but the system is
    # glibc 2.44 with a mesa requiring GLIBC_2.43. Hyprland dlopens that GBM
    # driver from /run/opengl-driver, so it must link the system glibc or it
    # aborts at startup ("MESA-LOADER: version GLIBC_2.43 not found" ->
    # "CBackend::create() failed!"). Deps (aquamarine/hyprutils/...) stay from
    # hyprland's own overlay, so plugins keep matching store paths.
    # MUST stay byte-identical to modules/system/config/desktop/default.nix or
    # the session package and the home-manager package diverge.
    # The v0.56.2 glaze problem is solved upstream of here, by pinning the
    # hyprland input's own nixpkgs in flake.nix -- do NOT add a postPatch here,
    # it would not reach the plugins' private Hyprland builds.
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland.override {
      stdenv = pkgs.stdenv;
    };
  };

}
