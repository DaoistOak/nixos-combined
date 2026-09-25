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

  # Login avatar. SDDM's greeter runs as the `sddm` user and reads it from
  # ~/.face, so it is installed by the activation script below (root) along
  # with the home-dir traversal permission.
  face = ./src/face.jpg;

  pixie =
    let
      base = inputs.pixie-sddm.packages.${pkgs.stdenv.hostPlatform.system}.pixie-sddm.override {
        background = "${./src/wallpaper}";
        accentColor = "#${themeSel.r.accent}";
        autoColor = false;
        backgroundColor = "#${themeSel.r.base}";
        textColor = "#${themeSel.r.text}";
        fontFamily = "JetBrains Mono";
        surfaceColor = "#${themeSel.r.surface1}";
        surfaceVariantColor = "#${themeSel.r.surface2}";
        subtextColor = "#${themeSel.r.subtext1}";
        mutedTextColor = "#${themeSel.r.subtext0}";
        errorColor = "#${themeSel.r.accents.red}";
      };
    in
    base.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.perl ];
      postPatch = old.postPatch + ''
        # Reduce the lock-screen clock size from 200 to 180 px and pull the two
        # stacked digit rows closer without letting them overlap.
        sed -i 's/font.pixelSize: 200/font.pixelSize: 180/g; s/spacing: -130/spacing: -30/g' components/Clock.qml

        # Use the active theme's surface/subtext/error colors instead of hardcoded ones.
        sed -i \
          -e 's|property color surfaceColor: Qt.lighter(baseColor, 1.3)|property color surfaceColor: config.surfaceColor|' \
          -e 's|property color surfaceVariantColor: Qt.lighter(baseColor, 1.6)|property color surfaceVariantColor: config.surfaceVariantColor|' \
          -e 's|color: loginState.isError ? "#442222" : baseColor|color: loginState.isError ? config.errorColor : baseColor|' \
          -e 's|color: "gray"|color: config.mutedTextColor|' \
          -e 's|color: isCurrent ? "white" : (hovered ? "#DDDDDD" : "#AAAAAA")|color: isCurrent ? config.textColor : (hovered ? config.subtextColor : config.mutedTextColor)|' \
          -e 's|color: isCurrent ? "white" : "#AAAAAA"|color: isCurrent ? config.textColor : config.mutedTextColor|' \
          -e 's|color: isCurrent ? baseColor : "white"|color: isCurrent ? baseColor : config.textColor|' \
          -e 's|color: isCurrent ? container.extractedAccent : "gray"|color: isCurrent ? container.extractedAccent : config.mutedTextColor|' \
          Main.qml

        # The four fallback "white" texts (user label, session name, password,
        # login button) sit on different backgrounds, so match by pixelSize.
        perl -0777 -pi -e '
          s/color: "white"\n\s*font.pixelSize: 24/color: config.textColor\n        font.pixelSize: 24/;
          s/color: "white"\n\s*font.pixelSize: 13/color: config.textColor\n        font.pixelSize: 13/;
          s/font.pixelSize: 18\n\s*color: "white"/font.pixelSize: 18\n        color: config.textColor/;
          s/color: "white"\n\s*font.pixelSize: 32/color: container.baseColor\n        font.pixelSize: 32/
        ' Main.qml
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

  # picwd uses FilesystemUserModel (UsesAccountsService defaults to false), so
  # the avatar must be readable by the sddm user at /home/<user>/.face. Install
  # it from the theme source and make the user's home dir traversable.
  system.activationScripts.sddm-face = {
    deps = [ "users" ];
    text = ''
      install -m 0644 -o ${config.var.username} -g users ${face} /home/${config.var.username}/.face
      chmod 0711 /home/${config.var.username}
    '';
  };

  environment.systemPackages = [ pixie ];
}
