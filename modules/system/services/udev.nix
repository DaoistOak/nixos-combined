{ config, pkgs, lib, ... }:
{
  # USB device ownership / power rules. The SPICE client (running as the user)
  # calls setfacl on USB device nodes during redirection, which requires file
  # ownership; grant the user ownership of USB device nodes. The MAC-based
  # interface naming and USB power-management rules are also shipped here.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb_device", ENV{DEVTYPE}=="usb_device", MODE="0660", OWNER="${config.var.username}", GROUP="users", TAG+="uaccess"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", MODE="0660", OWNER="${config.var.username}", GROUP="users", TAG+="uaccess"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="ec:91:61:47:2d:13", NAME="wlan0"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{authorized}=="1", ATTR{power/autosuspend}="1", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1ea7", ATTR{idProduct}=="0066", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="275d", ATTR{idProduct}=="0ba6", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1c4f", ATTR{idProduct}=="0048", ATTR{power/control}="on"
  '';
}
