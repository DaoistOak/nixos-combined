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

  xdg.dataFile = {
    "icons/hicolor/scalable/apps/ai-gemini.svg".source = ./src/icons/gemini.svg;
    "icons/hicolor/scalable/apps/ai-chatgpt.svg".source = ./src/icons/chatgpt.svg;
    "icons/hicolor/scalable/apps/ai-perplexity.svg".source = ./src/icons/perplexity.svg;
    "icons/hicolor/scalable/apps/ai-grok.svg".source = ./src/icons/grok.svg;
    "icons/hicolor/scalable/apps/ai-claude.svg".source = ./src/icons/claude.svg;
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
  };
}
