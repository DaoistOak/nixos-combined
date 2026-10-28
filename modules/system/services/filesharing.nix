{ config, pkgs, lib, ... }:
{
  # Samba network share of the user home, exposed to the LAN.
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
}
