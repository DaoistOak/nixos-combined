{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  themeMod = import ../../../home/config/themes/colors/themes.nix { inherit lib; };
  themeSel = themeMod.readSelection ../../../home/config/themes/colors/src/selection;

  pixie = inputs.pixie-sddm.packages.${pkgs.stdenv.hostPlatform.system}.pixie-sddm.override {
    background = "/var/lib/sddm/pixie-wallpaper";
    accentColor = "#${themeSel.r.accent}";
    autoColor = false;
    backgroundColor = "#${themeSel.r.base}";
    textColor = "#${themeSel.r.text}";
    fontFamily = "JetBrains Mono";
  };
in
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "pixie";
    extraPackages = with pkgs.kdePackages; [
      qtsvg
      qtdeclarative
      qt5compat
    ];
    settings.Theme.CursorTheme = "catppuccin-macchiato-light-cursors";
  };

  security.pam.services.sddm.enableKwallet = true;

  environment.systemPackages = [ pixie ];

  systemd.services.pixie-sddm-wallpaper = {
    description = "Sync Noctalia wallpaper into the SDDM pixie theme";
    wantedBy = [ "multi-user.target" ];
    before = [ "display-manager.service" ];
    path = [ pkgs.gawk ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      cfg="/home/zeph/.config/noctalia/noctalia-config.toml"
      dest="/var/lib/sddm/pixie-wallpaper"
      fallback="${./src/wallpaper}"
      wp=""
      if [ -r "$cfg" ]; then
        wp=$(awk '
          /^[[:space:]]*\[wallpaper\.last\]/ { inlast=1; next }
          inlast && /^[[:space:]]*\[/ { exit }
          inlast && /^[[:space:]]*path[[:space:]]*=[[:space:]]*"/ {
            sub(/^[[:space:]]*path[[:space:]]*=[[:space:]]*"/, "")
            sub(/".*/, "")
            print
            exit
          }
        ' "$cfg")
      fi
      if [ -n "$wp" ] && [ -f "$wp" ]; then
        install -o sddm -g sddm -m 0644 "$wp" "$dest"
      else
        install -o sddm -g sddm -m 0644 "$fallback" "$dest"
      fi
    '';
  };

  systemd.paths.pixie-sddm-wallpaper = {
    wantedBy = [ "multi-user.target" ];
    pathConfig.PathChanged = "/home/zeph/.config/noctalia/noctalia-config.toml";
  };
}
