{
  pkgs,
  ...
}:

let
  # hypridle tracks idle via the Wayland ext-idle-notify protocol, which only
  # sees keyboard/mouse events — controller input (/dev/input/js*) is invisible
  # to it, so controller-only gameplay dims/locks the screen. Steam/Firefox take
  # a DBus idle inhibitor; Lutris games don't (Hyprland provides no
  # org.freedesktop.ScreenSaver). This watchdog polls the joystick event nodes
  # and holds a logind idle inhibitor (honored by hypridle, whose
  # ignore_systemd_inhibit defaults to false) while the pad saw input in the
  # last INHIBIT_SECS seconds, so idle/lock still fires when the pad is put down.
  watchdogScript = pkgs.writeShellScript "gamepad-idle-inhibitor" ''
    set -uo pipefail

    DD=${pkgs.coreutils}/bin/dd
    WC=${pkgs.coreutils}/bin/wc
    DATE=${pkgs.coreutils}/bin/date
    SLEEP=${pkgs.coreutils}/bin/sleep
    INHIBIT=${pkgs.systemd}/bin/systemd-inhibit

    INHIBIT_SECS=150  # match hypridle's first listener (brightness dim)
    POLL_SECS=0.2
    REARM_SECS=1      # proactive refresh rate while active

    inhibit_pid=""
    last_activity=0
    last_arm=0

    release_inhibitor() {
      if [ -n "$inhibit_pid" ]; then
        kill "$inhibit_pid" 2>/dev/null
        wait "$inhibit_pid" 2>/dev/null
        inhibit_pid=""
      fi
    }

    # Overlap old and new locks so the bus never sees zero inhibitors mid-play
    # (a momentary gap would let hypridle fire its already-elapsed listeners).
    arm_inhibitor() {
      local old="$inhibit_pid"
      "$INHIBIT" --what=idle --who=gamepad-idle-inhibitor \
        --why="Gamepad in use" --mode=block sleep "$INHIBIT_SECS" &
      inhibit_pid=$!
      last_arm=$("$DATE" +%s)
      if [ -n "$old" ]; then
        kill "$old" 2>/dev/null
        wait "$old" 2>/dev/null
      fi
    }

    trap 'release_inhibitor; exit 0' INT TERM

    while true; do
      now=$("$DATE" +%s)
      for js in /dev/input/js*; do
        [ -e "$js" ] || continue
        # One js_event is 8 bytes; nonblocking read returns 0 bytes when idle.
        bytes=$("$DD" if="$js" bs=8 count=1 iflag=nonblock status=none 2>/dev/null | "$WC" -c)
        if [ "''${bytes:-0}" -ge 8 ]; then
          last_activity=$now
          break
        fi
      done

      if [ $((now - last_activity)) -lt "$INHIBIT_SECS" ]; then
        if [ -z "$inhibit_pid" ] || ! kill -0 "$inhibit_pid" 2>/dev/null \
          || [ $((now - last_arm)) -ge "$REARM_SECS" ]; then
          arm_inhibitor
        fi
      elif [ -n "$inhibit_pid" ]; then
        release_inhibitor
      fi

      "$SLEEP" "$POLL_SECS"
    done
  '';
in
{
  systemd.user.services.gamepad-idle-inhibitor = {
    Unit = {
      Description = "Hold an idle inhibitor while a gamepad is in use";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 3;
      ExecStart = watchdogScript;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
