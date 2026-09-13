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
    WP=${pkgs.wireplumber}/bin/wpctl

    # Phone playback is boosted to this node volume (2.0 = 200%) so the phone
    # doesn't play much quieter than laptop-local media on the same earbuds.
    PHONE_VOL="2.0"

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

    # Node ids of the phone's A2DP capture streams: remote source endpoints show
    # up as bluez_input nodes with media.class "Stream/Output/Audio" (the WOLF
    # SLEEK's own mic is Audio/Source and its internal capture is
    # Stream/Input/Audio, so neither matches).
    phone_nodes() {
      "$PW" ls Node 2>/dev/null | awk '
        /^[[:space:]]*id [0-9]+,/ {
          if (id != "" && nm ~ /bluez_input\./ && cls ~ /Stream\/Output\/Audio/) print id
          id = $2; sub(/,/, "", id); nm = ""; cls = ""
          next
        }
        /node.name =/ { nm = $0; next }
        /media.class =/ { cls = $0; next }
        END { if (id != "" && nm ~ /bluez_input\./ && cls ~ /Stream\/Output\/Audio/) print id }
      '
    }

    boost_phone() {
      local id cur
      for id in $(phone_nodes); do
        cur="$("$WP" get-volume "$id" 2>/dev/null | sed -n 's/^Volume: //p')"
        [ -n "$cur" ] || continue
        if awk -v c="$cur" -v t="$PHONE_VOL" 'BEGIN{exit !(c == t)}'; then
          continue
        fi
        "$WP" set-volume "$id" "$PHONE_VOL" 2>/dev/null
      done
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
        boost_phone
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
