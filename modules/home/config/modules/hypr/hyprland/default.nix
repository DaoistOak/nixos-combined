{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./settings/animations.nix
    ./settings/colors.nix
    ./settings/decorations.nix
    ./settings/displays.nix
    ./settings/dynamic-cursors.nix
    ./settings/edgehover.nix
    ./settings/hyprwinwrap.nix
    ./settings/input.nix
    ./settings/keybinds.nix
    ./settings/plugins.nix
    ./settings/scrolling.nix
    ./settings/scroll-overview.nix
    ./settings/misc.nix
    ./settings/startup.nix
    ./settings/windowrules.nix
    ./scripts/airplane-mode.nix
    ./scripts/ai-webapps.nix
    ./scripts/border-angle.nix
    ./scripts/border-rotate.nix
    ./scripts/brightness.nix
    ./scripts/hyprlock.nix
    ./scripts/cava-auto.nix
    ./scripts/launch-bluetooth.nix
    ./scripts/launch-network.nix
    ./scripts/launch-terminal.nix
    ./scripts/media-idle.nix
    ./scripts/mic-mute.nix
    ./scripts/noctalia-restart.nix
    ./scripts/performance-mode.nix
    ./scripts/session.nix
    ./scripts/super-tap-launcher.nix
    ./scripts/terminal-switcher
    ./scripts/submap-bar.nix
    ./scripts/submap-timeout.nix
    ./scripts/volume.nix
    ./scripts/widget-toggle.nix
  ];
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
