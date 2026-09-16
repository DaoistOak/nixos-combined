{
  config,
  pkgs,
  lib,
  ...
}: {
  virtualisation = {
    docker.enable = true;
    podman.enable = true;
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

  boot.kernelParams = [
    "kvm.ignore_msrs=1"
    "kvm.allow_unsafe_mmio_access=1"
  ];

  hardware.ksm.enable = true;

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "Lingnao (NixOS)";
        "netbios name" = "LINGNAO";
        security = "user";
        "map to guest" = "bad user";
        "guest account" = "nobody";
        "hosts allow" = "127.0.0.1 192.168.122.0/24";
        "hosts deny" = "0.0.0.0/0";
      };
      shared = {
        path = "/home/zeph";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = "zeph";
        "force group" = "users";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
    };
  };

  systemd.services.docker.wantedBy = lib.mkForce [ ];
  systemd.services.libvirtd.postStart = ''
    # Ensure the default NAT network exists (on-demand creation)
    if ! ${pkgs.libvirt}/bin/virsh net-info default >/dev/null 2>&1; then
      cat > /tmp/libvirt-default-net.xml <<'EOF'
<network>
  <name>default</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr0' stp='on' delay='0'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
EOF
      ${pkgs.libvirt}/bin/virsh net-define /tmp/libvirt-default-net.xml
      rm -f /tmp/libvirt-default-net.xml
    fi
    ${pkgs.libvirt}/bin/virsh net-start default 2>/dev/null || true
    ${pkgs.libvirt}/bin/virsh net-autostart default 2>/dev/null || true
  '';
  systemd.services.virtqemud.postStart = ''
    ${pkgs.libvirt}/bin/virsh net-start default 2>/dev/null || true
    ${pkgs.libvirt}/bin/virsh net-autostart default 2>/dev/null || true
  '';
  systemd.services."drkonqi-coredump-processor@".enable = false;
}
