{ config, pkgs, lib, ... }:
{
  # Virtualisation: containers + KVM. All share the same qemu_kvm + swtpm + a
  # virtiofsd shared-folder backend, plus the (optional) libvirt NAT network.
  virtualisation = {
    docker.enable = true;
    podman.enable = true;
    waydroid.enable = true;
    libvirtd = {
      enable = true;
      extraConfig = ''
        virtiofsd_path = "${pkgs.virtiofsd}/bin/virtiofsd"
      '';
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
  };
}
