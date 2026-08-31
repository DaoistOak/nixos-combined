{
  config,
  lib,
  pkgs,
  ...
}:

let
  crush = pkgs.nur.repos.charmbracelet.crush;
in
{
  home.packages = [ crush ];

  xdg.configFile."crush/crushrc" = {
    text = ''
      # Crush is configured via a Bash-flavored rc (see charmbracelet/crush
      # docs/config). This file runs when crush starts.
      #
      # Herdr integration: crush only exposes a single hook event (PreToolUse),
      # so the agent lifecycle can't be fully reported to herdr. Instead, this
      # registers a PreToolUse hook that reports `working` to the enclosing
      # herdr pane whenever crush starts a tool call. The script is a no-op
      # outside herdr (HERDR_ENV is unset), so it doesn't affect normal use.
      hook add PreToolUse \
        --command "${config.xdg.configHome}/crush/herdr-agent-state.sh" \
        --name herdr-agent-state
    '';
    force = true;
  };

  # Reports crush lifecycle state to the enclosing herdr pane through herdr's
  # socket API (see herdr.dev/docs/integrations -> "Integrate your own agent").
  # Fires from the PreToolUse hook above; exits 0 with no decision so the tool
  # call always proceeds and is non-blocking.
  xdg.configFile."crush/herdr-agent-state.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -uo pipefail

      # Only report when crush runs inside a herdr pane.
      if [[ "''${HERDR_ENV:-}" != "1" || -z "''${HERDR_BIN_PATH:-}" || -z "''${HERDR_PANE_ID:-}" ]]; then
        exit 0
      fi

      # PreToolUse fires right before a tool runs, so crush is actively working.
      # Use a strictly-increasing timestamp as the seq so out-of-order reports
      # from a busy hook can't clobber newer state.
      "$HERDR_BIN_PATH" pane report-agent "$HERDR_PANE_ID" \
        --source custom:crush \
        --agent crush \
        --state working \
        --seq "$(date +%s%N)" >/dev/null 2>&1 || true
    '';
    force = true;
  };
}
