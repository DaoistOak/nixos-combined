{
  pkgs,
  ...
}:

let
  # Bridge phone Bluetooth audio (phone -> PC -> WOLF SLEEK) only while the
  # WOLF SLEEK is connected. The phone arrives in PipeWire as an "Internal"
  # capture node `bluez_input.<mac>.*:output_F*`; WirePlumber auto-links such
  # nodes to whatever sink is available, so a plain pw-link would be re-created
  # by WirePlumber (or worse, routed to the laptop speakers when the earbuds are
  # off). This watchdog keeps the routing to the earbuds only, and tears it down
  # whenever the earbuds are not present (so the PC never acts as a sound device
  # for the phone on its own speakers).
  bridgeScript = pkgs.writeShellScript "phone-bt-bridge" ''
    set -uo pipefail

    PW=${pkgs.pipewire}/bin/pw-link

    # Output ports of phone bluetooth audio captures: bluez_input.<mac> nodes
    # that carry stereo output (output_FL/output_FR). The WOLF SLEEK's own mic
    # shows up as `bluez_input.B8:1D:33:BD:21:40:capture_MONO`, which does not
    # match, so it can never be routed back into itself.
    phone_ports() {
      "$PW" -o 2>/dev/null | awk '/^bluez_input\./ && /:output_F/ {print $1}'
    }

    # Playback port on the WOLF SLEEK sink for a channel (e.g. "FL"). Empty if
    # the earbuds are not connected.
    wolf_playback() {
      "$PW" -i 2>/dev/null | awk -v ch="$1" '
        $1 ~ "^bluez_output\\.B8_1D_33_BD_21_40.*:playback_" ch "$" {print $1; exit}
      '
    }

    has_link() {
      "$PW" -o 2>/dev/null | awk -v p="$1" '
        $0 == p {getline; if ($0 ~ /\|->/) exit 0} END {exit 1}
      '
    }

    get_target() {
      "$PW" -o 2>/dev/null | awk -v p="$1" '
        $0 == p {getline; if ($0 ~ /\|->/) {sub(/^[[:space:]]*\|->[[:space:]]*/, ""); print}}
      '
    }

    reconcile() {
      local port ch wolf tgt
      wolf="$(wolf_playback FL)"

      if [ -n "$wolf" ]; then
        # Earbuds present: point phone audio at them.
        for port in $(phone_ports); do
          ch="''${port##*:}"
          ch="''${ch#output_}"
          tgt="$(wolf_playback "$ch")"
          [ -n "$tgt" ] || continue
          if ! has_link "$port"; then
            "$PW" "$port" "$tgt" 2>/dev/null && echo "linked $port -> $tgt"
          fi
        done
      else
        # No earbuds: drop any existing forwarding so phone audio stays silent.
        for port in $(phone_ports); do
          tgt="$(get_target "$port")"
          [ -n "$tgt" ] || continue
          "$PW" -d "$port" "$tgt" 2>/dev/null && echo "unlinked $port -> $tgt (no WOLF SLEEK)"
        done
      fi
    }

    reconcile
    while true; do
      sleep 2
      reconcile
    done
  '';
in
{
  systemd.user.services.phone-bt-bridge = {
    Unit = {
      Description = "Bridge phone Bluetooth audio to WOLF SLEEK while connected";
      After = [ "wireplumber.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 3;
      ExecStart = bridgeScript;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
