# Browser integration for ungoogled-chromium.
#
# `programs.chromium.enable` is turned on by the stylix module (it injects the
# theme colour), and plasma6.nix enables
# `programs.chromium.enablePlasmaBrowserIntegration`.
#
# Extensions here are loaded unpacked via --load-extension (see
# pkgs/chromium-extensions), so their ids are derived from the injected keys in
# src/extensions.json instead of the Chrome Web Store ids the upstream host
# manifests whitelist. Native messaging refuses any other origin, so both hosts
# get an extra allowed origin for the packaged extension.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  chromium-extensions = pkgs.chromiumExtensions;
  updtScript = "${config.var.configDirectory}/scripts/updt";

  # Plasma's host package ships a manifest that only whitelists the store build,
  # so copy it and append our origin.
  plasmaOrigin = chromium-extensions.extensions.plasmaIntegration.host;
  plasmaBrowserIntegrationHost = pkgs.runCommand "plasma-browser-integration-host-manifest" { } ''
    mkdir -p "$out/etc/chromium/native-messaging-hosts"
    manifest="$out/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json"
    cp "${pkgs.kdePackages.plasma-browser-integration}/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json" "$manifest"
    chmod u+w "$manifest"
    "${pkgs.jq}/bin/jq" --arg origin "${plasmaOrigin}" \
      '.allowed_origins = (.allowed_origins // []) + [$origin]' \
      "$manifest" >"$manifest.tmp"
    mv "$manifest.tmp" "$manifest"
  '';

  # The weekly check runs as a system unit (home-manager's systemd.user.timers
  # option types reject plain values), so drop to the user session to get a bus
  # for notify-send. Check mode only reads the flake, it never writes.
  extCheckCommand = pkgs.writeShellScript "chromium-extensions-check" ''
    set -euo pipefail
    uid="$(id -u ${config.var.username})"
    exec ${pkgs.bash}/bin/bash -c '
      export FLAKE_PATH=${config.var.configDirectory}
      export XDG_RUNTIME_DIR="/run/user/$uid"
      export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus"
      exec ${pkgs.bash}/bin/bash ${updtScript} ext
    '
  '';
in
{
  programs.chromium = {
    # plasma6.nix sets this too, so ours has to win.
    plasmaBrowserIntegrationPackage = lib.mkForce plasmaBrowserIntegrationHost;
  };

  # KeePassXC ships a host manifest with the same store-only problem, and nothing
  # links it into /etc, so write our own.
  environment.etc."chromium/native-messaging-hosts/org.keepassxc.keepassxc_browser.json" = {
    text = builtins.toJSON {
      name = "org.keepassxc.keepassxc_browser";
      description = "KeePassXC integration with native messaging support";
      path = "${pkgs.keepassxc}/bin/keepassxc-proxy";
      type = "stdio";
      allowed_origins = [
        chromium-extensions.extensions.keepassxcBrowser.host
        # Store builds, so a manually installed copy keeps working too.
        "chrome-extension://iopaggbpplllidnfmcghoonnokmjoicf/"
        "chrome-extension://oboonakemofpalcgghocfoadofidjkkk/"
        "chrome-extension://pdffhmdngciaglkoonimfcmckehcpafo/"
      ];
    };
  };

  # Chromium can't update unpacked extensions, so poll upstream once a week and
  # notify; applying is `updt ext --apply` (bumps pins, rebuilds, switches).
  systemd.services.chromium-extensions-check = {
    description = "Check for Chromium extension updates";
    wantedBy = [ "timers.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/runuser -u ${config.var.username} -- ${extCheckCommand}";
    };
    # systemd's default PATH is coreutils-only, but ext_check needs these.
    environment.PATH = lib.mkForce (
      lib.makeBinPath [
        pkgs.bash
        pkgs.coreutils
        pkgs.curl
        pkgs.findutils
        pkgs.gawk
        pkgs.git
        pkgs.gnugrep
        pkgs.gnused
        pkgs.jq
        pkgs.nix
      ]
    );
  };

  systemd.timers.chromium-extensions-check = {
    description = "Weekly Chromium extension update check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon 04:17";
      RandomizedDelaySec = "30m";
      Persistent = true;
    };
  };

  assertions = [
    {
      assertion = lib.hasAttr "loadArg" chromium-extensions;
      message = "pkgs.chromiumExtensions overlay is missing (check overlays/default.nix)";
    }
  ];
}
