{ config, pkgs, lib, ... }:
{
  # hardware.uinput + makima virtual gamepad. The device is owned by root:uinput
  # 0660; a running session cannot add a group at runtime, so grant an ACL in
  # udev (re-applied on every trigger) and keep the user in the `input` group so
  # it works after a re-login too.
  hardware.uinput.enable = true;
  users.groups.uinput.members = [ config.var.username ];
  services.udev.packages = [
    pkgs.game-devices-udev-rules
    (pkgs.writeTextDir "etc/udev/rules.d/99-makima.rules" ''
      SUBSYSTEM=="misc", KERNEL=="uinput", MODE="0660", GROUP="input", TAG+="uaccess", RUN+="${pkgs.acl}/bin/setfacl -m u:${config.var.username}:rw /dev/uinput"
    ''')
  ];
}
