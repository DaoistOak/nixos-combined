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

  services.udev.extraRules = ''
    # SPICE client (running as ${config.var.username}) calls setfacl on USB device nodes
    # during redirection. setfacl requires file ownership, so make ${config.var.username}
    # the owner of USB device nodes.
    SUBSYSTEM=="usb_device", ENV{DEVTYPE}=="usb_device", MODE="0660", OWNER="${config.var.username}", GROUP="users", TAG+="uaccess"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", MODE="0660", OWNER="${config.var.username}", GROUP="users", TAG+="uaccess"
  '';

  hardware.uinput.enable = true;

  # makima creates virtual input devices through /dev/uinput, which hardware.uinput
  # leaves as root:uinput 0660. A running session's supplementary groups are fixed
  # at login, so adding the user to a group does not reach a session that is already
  # up — grant an ACL instead (re-applied on every udev trigger), and set the group
  # to `input` so it also works after a re-login.
  users.groups.uinput.members = [ config.var.username ];
  services.udev.packages = [
    pkgs.game-devices-udev-rules
    (pkgs.writeTextDir "etc/udev/rules.d/99-makima.rules" ''
      SUBSYSTEM=="misc", KERNEL=="uinput", MODE="0660", GROUP="input", TAG+="uaccess", RUN+="${pkgs.acl}/bin/setfacl -m u:${config.var.username}:rw /dev/uinput"
    '')
  ];

  # kernelParams (kvm.ignore_msrs=1) are owned by ../config/hardware/default.nix (single mkForce).

  hardware.ksm.enable = true;

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "${config.var.hostname} (NixOS)";
        "netbios name" = "LINGNAO";
        security = "user";
        "map to guest" = "bad user";
        "guest account" = "nobody";
        "hosts allow" = "127.0.0.1 192.168.122.0/24";
        "hosts deny" = "0.0.0.0/0";
      };
      shared = {
        path = "/home/${config.var.username}";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "force user" = config.var.username;
        "force group" = "users";
        "create mask" = "0664";
        "directory mask" = "0775";
      };
    };
  };

  # gamepad access: the game-devices-udev-rules package is listed in
  # services.udev.packages above (alongside the makima uinput rule).
  systemd.services.libvirtd.postStart = ''
        # Ensure the default NAT network exists (on-demand creation).
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
