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

        # Fix avatar: source the machine-local face image directly in QML. SDDM's
        # user-model lookup (IconRole = UserRole+4, fs model needs ~/.face.icon)
        # proved unreliable in practice, so hardcode the initial source. If the
        # model later yields a valid image URL it resolves to the same file.
        sed -i 's|var s = Qt.resolvedUrl("assets/avatar.jpg");|var s = "file:///home/zeph/.face.icon";|' Main.qml

        # Fix avatar warping: pin the avatar to a square source and center-crop
        # it in the Canvas, instead of stretching the full photo into the circle.
        sed -i 's|^                            fillMode: Image.PreserveAspectCrop$|&\n                            sourceSize: Qt.size(120, 120)|' Main.qml
        sed -i 's#ctx.drawImage(avatar, 0, 0, width, height);#var iw = avatar.sourceSize.width || width;\nvar ih = avatar.sourceSize.height || height;\nvar side = Math.min(iw, ih);\nvar sx = (iw - side) / 2;\nvar sy = (ih - side) / 2;\nctx.drawImage(avatar, sx, sy, side, side, 0, 0, width, height);#' Main.qml

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

    # AccountsService is installed (pulled in by Plasma) and SDDM defaults to
    # the AccountsService user model when its daemon is running — but we don't
    # seed /var/lib/AccountsService, so the greeter never sees icons and pixie
    # falls back to its bundled default avatar.jpg. Force the filesystem model
    # so the avatar is read from ~/.face (installed by the activation script).
    settings.Users.UsesAccountsService = false;
  };

  security.pam.services.sddm.enableKwallet = true;

  # pixie uses SDDM's filesystem user model with UsesAccountsService=false, so
  # the avatar must be readable by the sddm user. SDDM 0.21 only looks for
  # ~/.face.icon (checks systemFace first, then <home>/.face.icon) — NOT
  # ~/.face — so install the image under both names and make the home dir
  # traversable.
  system.activationScripts.sddm-face = {
    deps = [ "users" ];
    text = ''
      install -m 0644 -o ${config.var.username} -g users ${face} /home/${config.var.username}/.face
      install -m 0644 -o ${config.var.username} -g users ${faceSq}/face.png /home/${config.var.username}/.face.icon
      chmod 0711 /home/${config.var.username}
    '';
  };

  environment.systemPackages = [ pixie ];
}
