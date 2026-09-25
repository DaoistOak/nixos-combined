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

  # Login avatar. SDDM's greeter runs as the `sddm` user. We seed the profile
  # picture the standard way — where KDE Plasma and other SDDM greeters expect
  # it:
  #   - /var/lib/AccountsService/icons/<user>  (AccountsService icon)
  #   - ~/.face and ~/.face.icon               (home-dir standard)
  face = ./src/face.jpg;

  # Square avatar crop for the login circle: side = min(w,h), centered at
  # (w/2, h/2) — the canonical center square.
  faceSq = pkgs.runCommand "face-square" {
    nativeBuildInputs = [ pkgs.imagemagick ];
  } ''
    mkdir -p $out
    magick '${face}' -auto-orient -crop '%[fx:min(w,h)]x%[fx:min(w,h)]+%[fx:(w-min(w,h))/2]+%[fx:(h-min(w,h))/2]' +repage -resize 512x512 "$out/face.png"
  '';

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

        # Fix avatar: SDDM's IconRole is UserRole+4 (roles: +1 Name, +2
        # RealName, +3 HomeDir, +4 Icon), but pixie reads +3 — the home dir —
        # so the model icon never matches and it falls back to the bundled
        # assets/avatar.jpg. Read the right role; the icon itself is resolved
        # the standard way (see sddm-face activation script below).
        sed -i 's/Qt.UserRole + 3/Qt.UserRole + 4/' Main.qml

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

    # AccountsService is installed (pulled in by Plasma); keep the filesystem
    # user model (UsesAccountsService=false) — it resolves icons by priority
    # FacesDir -> ~/.face.icon -> /var/lib/AccountsService/icons, all seeded
    # by the sddm-face activation script below.
    settings.Users.UsesAccountsService = false;
  };

  security.pam.services.sddm.enableKwallet = true;

  # Seed the profile picture at the standard locations the greeter's user model
  # resolves (priority: SDDM FacesDir -> ~/.face.icon -> AccountsService icon
  # dir), exactly like KDE Plasma's user manager does. Also keep the home dir
  # traversable for the sddm user.
  system.activationScripts.sddm-face = {
    deps = [ "users" ];
    text = ''
      install -d -m 0755 /var/lib/AccountsService/icons
      install -m 0644 -o ${config.var.username} -g users ${faceSq}/face.png /var/lib/AccountsService/icons/${config.var.username}
      install -m 0644 -o ${config.var.username} -g users ${face} /home/${config.var.username}/.face
      install -m 0644 -o ${config.var.username} -g users ${faceSq}/face.png /home/${config.var.username}/.face.icon
      chmod 0711 /home/${config.var.username}
    '';
  };

  environment.systemPackages = [ pixie ];
}
