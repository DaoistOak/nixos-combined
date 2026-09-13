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
      # window, each with its own profile dir. If the window already exists it
      # is focused instead of spawning a duplicate.
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
      profile="''${XDG_CONFIG_HOME:-$HOME/.config}/ai-webapps/$app"
      mkdir -p "$profile"

      # Focus an already-open app window, else start one.
      if hyprctl clients -j 2>/dev/null | jq -e --arg c "$class" 'any(.[]; .class == $c)' >/dev/null 2>&1; then
        hyprctl dispatch focuswindow "class:$class" >/dev/null 2>&1
        exit 0
      fi

      nohup chromium \
        --app="$url" \
        --user-data-dir="$profile" \
        --class="$class" \
        --no-first-run >/dev/null 2>&1 &
    '';
  };

  xdg.desktopEntries = {
    gemini = {
      name = "Gemini";
      exec = "${launchScript} gemini";
      terminal = false;
      categories = [ "Network" ];
      comment = "Google Gemini (AI web app)";
    };
    chatgpt = {
      name = "ChatGPT";
      exec = "${launchScript} chatgpt";
      terminal = false;
      categories = [ "Network" ];
      comment = "OpenAI ChatGPT (AI web app)";
    };
    perplexity = {
      name = "Perplexity";
      exec = "${launchScript} perplexity";
      terminal = false;
      categories = [ "Network" ];
      comment = "Perplexity AI (AI web app)";
    };
    grok = {
      name = "Grok";
      exec = "${launchScript} grok";
      terminal = false;
      categories = [ "Network" ];
      comment = "xAI Grok (AI web app)";
    };
    claude = {
      name = "Claude";
      exec = "${launchScript} claude";
      terminal = false;
      categories = [ "Network" ];
      comment = "Anthropic Claude (AI web app)";
    };
  };
}
