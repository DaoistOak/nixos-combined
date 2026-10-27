{
  config,
  pkgs,
  ...
}:

let
  launchScript = "${config.xdg.configHome}/hypr/scripts/launch-ai.sh";
in
{
  xdg.configFile."hypr/scripts/launch-ai.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Launch (or focus) one of the AI web apps in a standalone Chromium app
      # window using the default Chromium profile. If the window already exists
      # it is focused instead of spawning a duplicate.
      # Usage: launch-ai.sh {gemini|chatgpt|perplexity|grok|claude}
      set -euo pipefail

      declare -A URLS=(
        [gemini]="https://gemini.google.com"
        [chatgpt]="https://chatgpt.com"
        [perplexity]="https://www.perplexity.ai"
        [grok]="https://grok.com"
        [claude]="https://claude.ai"
      )

      app="''${1:-}"
      url="''${URLS[$app]:-}"
      if [[ -z "$url" ]]; then
        echo "usage: launch-ai.sh {gemini|chatgpt|perplexity|grok|claude}" >&2
        exit 1
      fi

      class="AI-$app"

      # Focus an already-open app window, else start one.
      if hyprctl clients -j 2>/dev/null | jq -e --arg c "$class" 'any(.[]; .class == $c)' >/dev/null 2>&1; then
        hyprctl dispatch focuswindow "class:$class" >/dev/null 2>&1
        exit 0
      fi

      # No --user-data-dir: the app window joins the default Chromium profile,
      # so it inherits the main browser's extensions (Stylus), their stored
      # data and cookies. Chromium hands the request to the already-running
      # browser process when one is up.
      nohup chromium \
        --app="$url" \
        --class="$class" \
        --no-first-run \
        --password-store=basic >/dev/null 2>&1 &
    '';
  };

  xdg.configFile."hypr/scripts/launch-ai-opencode.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Launch (or focus) the OpenCode web UI in a standalone Chromium app window.
      # Usage: launch-ai-opencode.sh
      # If an opencode window is already open, focus it instead of spawning a new one.
      set -euo pipefail

      class="opencode"

      # Focus an already-open opencode window, else start one.
      if hyprctl clients -j 2>/dev/null | jq -e --arg c "$class" 'any(.[]; .class == $c)' >/dev/null 2>&1; then
        hyprctl dispatch focuswindow "class:$class" >/dev/null 2>&1
        exit 0
      fi

      # Kill any stale opencode server on the port, then start a fresh one.
      if command -v lsof >/dev/null 2>&1; then
        lsof -ti:4096 2>/dev/null | xargs -r kill 2>/dev/null || true
      elif command -v fuser >/dev/null 2>&1; then
        fuser -k 4096/tcp 2>/dev/null || true
      fi
      sleep 0.5

      nohup opencode web --port 4096 >/dev/null 2>&1 &
      OPCODE_PID=$!

      # Wait for the server to be ready.
      for i in $(seq 1 40); do
        if curl -s http://127.0.0.1:4096 >/dev/null 2>&1; then
          break
        fi
        sleep 0.25
      done

      # Verify the server is up.
      if ! curl -s http://127.0.0.1:4096 >/dev/null 2>&1; then
        echo "opencode web failed to start on port 4096" >&2
        kill "$OPCODE_PID" 2>/dev/null || true
        exit 1
      fi

      nohup chromium \
        --app="http://127.0.0.1:4096" \
        --class="$class" \
        --no-first-run \
        --password-store=basic >/dev/null 2>&1 &

      # Leave the opencode server running so the window stays connected.
      disown
    '';
  };

  xdg.configFile."hypr/scripts/launch-ai-hermes.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Launch (or focus) the Hermes web UI in a standalone Chromium app window.
      # Usage: launch-ai-hermes.sh
      # If a hermes window is already open, focus it instead of spawning a new one.
      set -euo pipefail

      class="hermes"
      url="http://127.0.0.1:9119"

      # Focus an already-open hermes window, else start one.
      if hyprctl clients -j 2>/dev/null | jq -e --arg c "$class" 'any(.[]; .class == $c)' >/dev/null 2>&1; then
        hyprctl dispatch focuswindow "class:$class" >/dev/null 2>&1
        exit 0
      fi

      # Start the Hermes dashboard server (no browser auto-open).
      hermes dashboard --no-open >/dev/null 2>&1 &
      HERMES_PID=$!

      # Wait for the server to be ready.
      for i in $(seq 1 40); do
        if curl -s http://127.0.0.1:9119 >/dev/null 2>&1; then
          break
        fi
        sleep 0.25
      done

      # Verify the server is up.
      if ! curl -s http://127.0.0.1:9119 >/dev/null 2>&1; then
        echo "hermes dashboard failed to start on port 9119" >&2
        kill "$HERMES_PID" 2>/dev/null || true
        exit 1
      fi

      nohup chromium \
        --app="$url" \
        --class="$class" \
        --no-first-run \
        --password-store=basic >/dev/null 2>&1 &

      # Leave the hermes server running so the window stays connected.
      disown
    '';
  };

  xdg.dataFile = {
    "icons/hicolor/scalable/apps/ai-gemini.svg".source = ./src/icons/gemini.svg;
    "icons/hicolor/scalable/apps/ai-chatgpt.svg".source = ./src/icons/chatgpt.svg;
    "icons/hicolor/scalable/apps/ai-perplexity.svg".source = ./src/icons/perplexity.svg;
    "icons/hicolor/scalable/apps/ai-grok.svg".source = ./src/icons/grok.svg;
    "icons/hicolor/scalable/apps/ai-claude.svg".source = ./src/icons/claude.svg;
    "icons/hicolor/scalable/apps/ai-opencode.svg".source = ./src/icons/opencode.svg;
    "icons/hicolor/scalable/apps/ai-hermes.svg".source = ./src/icons/hermes.svg;
  };

  xdg.desktopEntries = {
    gemini = {
      name = "Gemini";
      exec = "${launchScript} gemini";
      terminal = false;
      categories = [ "Network" ];
      comment = "Google Gemini (AI web app)";
      icon = "ai-gemini";
    };
    chatgpt = {
      name = "ChatGPT";
      exec = "${launchScript} chatgpt";
      terminal = false;
      categories = [ "Network" ];
      comment = "OpenAI ChatGPT (AI web app)";
      icon = "ai-chatgpt";
    };
    perplexity = {
      name = "Perplexity";
      exec = "${launchScript} perplexity";
      terminal = false;
      categories = [ "Network" ];
      comment = "Perplexity AI (AI web app)";
      icon = "ai-perplexity";
    };
    grok = {
      name = "Grok";
      exec = "${launchScript} grok";
      terminal = false;
      categories = [ "Network" ];
      comment = "xAI Grok (AI web app)";
      icon = "ai-grok";
    };
    claude = {
      name = "Claude";
      exec = "${launchScript} claude";
      terminal = false;
      categories = [ "Network" ];
      comment = "Anthropic Claude (AI web app)";
      icon = "ai-claude";
    };
    opencode = {
      name = "OpenCode";
      exec = "${launchScript} opencode";
      terminal = false;
      categories = [ "Network" ];
      comment = "OpenCode web UI (AI coding agent)";
      icon = "ai-opencode";
    };
    hermes = {
      name = "Hermes";
      exec = "${launchScript} hermes";
      terminal = false;
      categories = [ "Network" ];
      comment = "Hermes web UI (AI agent dashboard)";
      icon = "ai-hermes";
    };
  };
}
