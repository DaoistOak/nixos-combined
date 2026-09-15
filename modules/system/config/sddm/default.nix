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

  pixie = let
    base = inputs.pixie-sddm.packages.${pkgs.stdenv.hostPlatform.system}.pixie-sddm.override {
    background = "${./src/wallpaper}";
    accentColor = "#${themeSel.r.accent}";
    autoColor = false;
    backgroundColor = "#${themeSel.r.base}";
    textColor = "#${themeSel.r.text}";
    fontFamily = "JetBrains Mono";
    };
  in
  base.overrideAttrs (old: {
    postPatch = old.postPatch + ''
      # Reduce the lock-screen clock size from 200 to 180 px
      sed -i 's/font.pixelSize: 200/font.pixelSize: 180/' components/Clock.qml
    '';
  });
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
}
