{ config, pkgs, lib, inputs, ... }:
let
  # 16-color ANSI palette -> kernel vt.default_{red,grn,blu} args. The theme
  # DB is the single source of truth for the accent colour (same module as
  # sddm/themer). NixOS injects these via boot.kernelParams, so spell them out
  # here explicitly or the TTY keeps the default VGA colours.
  themeMod = import ../../../home/config/themes/colors/_themes.nix { inherit lib; };
  themeSel = themeMod.readSelection ../../../home/config/themes/colors/src/selection;
  vtChannels =
    let
      allRed = builtins.concatStringsSep "," (builtins.map (c: "0x${builtins.substring 0 2 c}") themeSel.r.ansi);
      allGrn = builtins.concatStringsSep "," (builtins.map (c: "0x${builtins.substring 2 2 c}") themeSel.r.ansi);
      allBlu = builtins.concatStringsSep "," (builtins.map (c: "0x${builtins.substring 4 2 c}") themeSel.r.ansi);
    in
      [ allRed allGrn allBlu ];

  # Plymouth boot splash. The stock nixos-loading-white theme is copied and
  # recolored to the theme-changer accent at build time. The theme path
  # is provided by the nixos-loading-plymouth input (patched with the
  # desired accent). The white variant ships transparent-bg PNG frames of
  # the wordmark + lambda arms; -colorize swaps white to the accent while
  # keeping the anti-aliased luminance ramp and the theme's own dark
  # gradient background.
  nixosLoadingTheme = pkgs.runCommand "plymouth-nixos-loading-${themeSel.r.accent}" { } ''
    themeDir="$out/share/plymouth/themes/nixos-loading-white"
    mkdir -p "$themeDir"
    cp -r ${inputs.nixos-loading-plymouth.packages.${pkgs.stdenv.hostPlatform.system}.nixos-loading-white}/share/plymouth/themes/nixos-loading-white/* "$themeDir/"
    for f in "$themeDir"/frame-*.png; do
      chmod u+w "$f"
      ${pkgs.imagemagick}/bin/magick "$f" -fill '#${themeSel.r.accent}' -colorize 100 "$f"
    done
  '';
in
{
  # Do not power on bluetooth adapter at boot; user toggles it manually via keybind.
  hardware.bluetooth.powerOnBoot = false;

  # Single owner of boot.kernelParams (mkForce): the list that has been
  # verified to boot (quiet, splash, the amdgpu runtime-PM flags, kvm.ignore_msrs,
  # nvme latency, etc.) + kvm.allow_unsafe_mmio_access=0 + zswap.enabled=0.
  # This is the only place boot.kernelParams is mkForced, so the cmdline is
  # deterministic and the same across every system module.
  boot.kernelParams = lib.mkForce [
    "vt.default_red=${builtins.elemAt vtChannels 0}"
    "vt.default_grn=${builtins.elemAt vtChannels 1}"
    "vt.default_blu=${builtins.elemAt vtChannels 2}"
    "quiet"
    "splash"
    "rd.systemd.show_status=auto"
    "amdgpu.runpm=1"
    "amdgpu.gpu_recovery=0"
    "amdgpu.dcdebugmask=0"
    "kvm.ignore_msrs=1"
    "kvm.allow_unsafe_mmio_access=0"
    "zswap.enabled=0"
    "amdgpu.sg_display=0"
    "resume=UUID=c90cb3d2-feba-424e-a25b-146d24f9bd0d"
  ];

  # Plymouth boot splash. The stock nixos-loading-white theme is copied and
  # recolored to the theme-changer accent at build time. The theme path
  # is provided by the nixos-loading-plymouth input (patched with the
  # desired accent). The white variant ships transparent-bg PNG frames of
  # the wordmark + lambda arms; -colorize swaps white to the accent while
  # keeping the anti-aliased luminance ramp and the theme's own dark
  # gradient background.
  boot.plymouth = {
    theme = "nixos-loading-white";
    themePackages = [ nixosLoadingTheme ];
  };
  boot.consoleLogLevel = 3;

}
