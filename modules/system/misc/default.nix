{
  config,
  pkgs,
  lib,
  ...
}:
{
  virtualisation = {
    docker.enable = true;
    podman.enable = true;
    libvirtd = {
      enable = true;
      extraConfig = ''
        virtiofsd_path = "${pkgs.qemu}/bin/virtiofsd"
      '';
    };
  };

  systemd.services.docker.wantedBy = lib.mkForce [ ];
  systemd.services.libvirtd.postStart = ''
    ${pkgs.libvirt}/bin/virsh net-start default 2>/dev/null || true
    ${pkgs.libvirt}/bin/virsh net-autostart default 2>/dev/null || true
  '';
  systemd.services.virtqemud.postStart = ''
    ${pkgs.libvirt}/bin/virsh net-start default 2>/dev/null || true
    ${pkgs.libvirt}/bin/virsh net-autostart default 2>/dev/null || true
  '';
  systemd.services."drkonqi-coredump-processor@".enable = false;
}
