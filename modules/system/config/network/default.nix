{ ... }:
{
  networking = {
    hostName = "Lingnao";
    networkmanager.enable = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = [
        "virbr0"
        "virbr1"
      ];
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
      allowedUDPPortRanges = [
        {
          from = 1714;
          to = 1764;
        } # KDE Connect
      ];
    };
  };

  time.timeZone = "Asia/Kathmandu";
  i18n.defaultLocale = "en_US.UTF-8";
}
