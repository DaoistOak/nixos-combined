{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption types mkIf;

  # ---------------------------------------------------------------------------
  # Generic theme database.
  #
  # Every theme exposes the same shape:
  #   <theme> = {
  #     title    = "Human readable name";
  #     variants = {
  #       <variant> = {
  #         title    = "Human readable variant name";
  #         polarity = "dark" | "light";
  #         roles    = { ... };   # normalized role colors (raw hex, no '#')
  #         accents  = { <accent> = "hex"; ... };
  #       };
  #     };
  #   }
  #
  # `roles` is a normalized, theme-agnostic set of colors so the runtime
  # switcher + terminal templates don't care which theme they apply to. Adding
  # a new theme (e.g. Dracula) is just: append an attrset + give it roles.
  #
  # Normalized roles (raw hex, no '#'):
  #   bg, fg                 -> terminal background / foreground
  #   base, mantle, crust    -> background tiers (crust = darkest)
  #   surface0..surface2     -> elevated UI surfaces
  #   overlay0..overlay2     -> muted/disabled surfaces
  #   subtext0..subtext1     -> secondary text
  #   text                   -> primary text
  #   accent                 -> primary accent (resolved from the accent arg)
  #   ansi                   -> 16 colors for terminals
  # ---------------------------------------------------------------------------
  themes = {
    catppuccin = {
      title = "Catppuccin";
      flavors = rec {
        latte = {
          title = "Latte";
          polarity = "light";
          base = "eff1f5";
          mantle = "e6e9ef";
          crust = "dce0e8";
          surface0 = "ccd0da";
          surface1 = "bcc0cc";
          surface2 = "acb0be";
          overlay0 = "9ca0b0";
          overlay1 = "8c8fa1";
          overlay2 = "7c7f93";
          subtext0 = "6c6f85";
          subtext1 = "5c5f77";
          text = "4c4f69";
          accents = {
            lavender = "7287fd";
            blue = "1e66f5";
            sapphire = "209fb5";
            cyan = "04a5e5";
            teal = "179299";
            green = "40a02b";
            yellow = "df8e1d";
            peach = "fe640b";
            maroon = "e64553";
            red = "d20f39";
            mauve = "8839ef";
            pink = "ea76cb";
            flamingo = "dd7878";
            rosewater = "dc8a78";
          };
          # 16 ANSI colors (black red green yellow blue magenta cyan white +
          # brights). Explicit per variant so any theme can be expressed.
          ansi = [
            "dce0e8"
            "d20f39"
            "40a02b"
            "df8e1d"
            "1e66f5"
            "8839ef"
            "179299"
            "5c5f77"
            "9ca0b0"
            "e64553"
            "40a02b"
            "df8e1d"
            "1e66f5"
            "ea76cb"
            "179299"
            "6c6f85"
          ];
        };
        frappe = {
          title = "Frappe";
          polarity = "dark";
          base = "303446";
          mantle = "292c3c";
          crust = "232634";
          surface0 = "414559";
          surface1 = "51576d";
          surface2 = "626880";
          overlay0 = "737994";
          overlay1 = "838ba7";
          overlay2 = "949cbb";
          subtext0 = "a5adce";
          subtext1 = "b5bfe2";
          text = "c6d0f5";
          accents = {
            lavender = "babbf1";
            blue = "8caaee";
            sapphire = "85c1dc";
            cyan = "99d1db";
            teal = "81c8be";
            green = "a6d189";
            yellow = "e5c890";
            peach = "ef9f76";
            maroon = "ea999c";
            red = "e78284";
            mauve = "ca9ee6";
            pink = "f4b8e4";
            flamingo = "eebebe";
            rosewater = "f2d5cf";
          };
          ansi = [
            "232634"
            "e78284"
            "a6d189"
            "e5c890"
            "8caaee"
            "ca9ee6"
            "81c8be"
            "b5bfe2"
            "737994"
            "ea999c"
            "a6d189"
            "e5c890"
            "8caaee"
            "f4b8e4"
            "81c8be"
            "a5adce"
          ];
        };
        macchiato = {
          title = "Macchiato";
          polarity = "dark";
          base = "24273a";
          mantle = "1e2030";
          crust = "181926";
          surface0 = "363a4f";
          surface1 = "494d64";
          surface2 = "5b6078";
          overlay0 = "6e738d";
          overlay1 = "8087a2";
          overlay2 = "939ab7";
          subtext0 = "a5adcb";
          subtext1 = "b8c0e0";
          text = "cad3f5";
          accents = {
            lavender = "b7bdf8";
            blue = "8aadf4";
            sapphire = "7dc4e4";
            cyan = "91d7e3";
            teal = "8bd5ca";
            green = "a6da95";
            yellow = "eed49f";
            peach = "f5a97f";
            maroon = "ee99a0";
            red = "ed8796";
            mauve = "c6a0f6";
            pink = "f5bde6";
            flamingo = "f0c6c6";
            rosewater = "f4dbd6";
          };
          ansi = [
            "181926"
            "ed8796"
            "a6da95"
            "eed49f"
            "8aadf4"
            "c6a0f6"
            "8bd5ca"
            "b8c0e0"
            "6e738d"
            "ee99a0"
            "a6da95"
            "eed49f"
            "8aadf4"
            "f5bde6"
            "8bd5ca"
            "a5adcb"
          ];
        };
        mocha = {
          title = "Mocha";
          polarity = "dark";
          base = "1e1e2e";
          mantle = "181825";
          crust = "11111b";
          surface0 = "313244";
          surface1 = "45475a";
          surface2 = "585b70";
          overlay0 = "6c7086";
          overlay1 = "7f849c";
          overlay2 = "9399b2";
          subtext0 = "a6adc8";
          subtext1 = "bac2de";
          text = "cdd6f4";
          accents = {
            lavender = "b4befe";
            blue = "89b4fa";
            sapphire = "74c7ec";
            cyan = "89dceb";
            teal = "94e2d5";
            green = "a6e3a1";
            yellow = "f9e2af";
            peach = "fab387";
            maroon = "eba0ac";
            red = "f38ba8";
            mauve = "cba6f7";
            pink = "f5c2e7";
            flamingo = "f2cdcd";
            rosewater = "f5e0dc";
          };
          ansi = [
            "11111b"
            "f38ba8"
            "a6e3a1"
            "f9e2af"
            "89b4fa"
            "cba6f7"
            "94e2d5"
            "bac2de"
            "6c7086"
            "eba0ac"
            "a6e3a1"
            "f9e2af"
            "89b4fa"
            "f5c2e7"
            "94e2d5"
            "a6adc8"
          ];
        };
      };
    };

    # Blueprint for a non-Catppuccin theme. Add more themes by appending their
    # data here; the normalized `roles` keep the runtime switcher theme-agnostic.
    dracula = {
      title = "Dracula";
      flavors = {
        dark = {
          title = "Dark";
          polarity = "dark";
          # Dracula canonical palette mapped onto normalized roles.
          base = "282a36"; # background
          mantle = "21222c"; # darker variant
          crust = "1d1e26"; # terminal/dimmer bg
          surface0 = "343746";
          surface1 = "44475a"; # current line / selection
          surface2 = "55586b";
          overlay0 = "6272a4"; # comment
          overlay1 = "6b7ab5";
          overlay2 = "7483c6";
          subtext0 = "9aa0b4";
          subtext1 = "c9ced8";
          text = "f8f8f2"; # foreground
          accents = {
            default = "bd93f9"; # purple
            purple = "bd93f9";
            green = "50fa7b";
            cyan = "8be9fd";
            pink = "ff79c6";
            red = "ff5555";
            orange = "ffb86c";
            yellow = "f1fa8c";
          };
          # Dracula ANSI (loosely conventional mapping).
          ansi = [
            "21222c" # black
            "ff5555" # red
            "50fa7b" # green
            "f1fa8c" # yellow
            "6272a4" # blue (comment-ish)
            "bd93f9" # magenta
            "8be9fd" # cyan
            "f8f8f2" # white
            "6272a4" # bright black (comment)
            "ff6e7e" # bright red
            "69ff94" # bright green
            "ffffa5" # bright yellow
            "d6acff" # bright blue
            "ff92df" # bright magenta
            "a4ffff" # bright cyan
            "ffffff" # bright white
          ];
        };
      };
    };
  };

  # Resolve a raw variant slot into normalized roles given a chosen accent name.
  # Returns raw hex (no '#').
  resolve = v: accent: {
    polarity = v.polarity;
    title = v.title;
    accentName = accent;
    accent =
      v.accents.${accent} or v.accents.default or (builtins.head (builtins.attrValues v.accents));
    inherit (v)
      base
      mantle
      crust
      surface0
      surface1
      surface2
      overlay0
      overlay1
      overlay2
      subtext0
      subtext1
      text
      ansi
      ;
  };

  # Build the full machine-readable themes JSON the CLI consumes.
  themesJSON = lib.mapAttrs (_: t: {
    title = t.title;
    flavors = lib.mapAttrs (_: v: {
      title = v.title;
      polarity = v.polarity;
      inherit (v)
        base
        mantle
        crust
        surface0
        surface1
        surface2
        overlay0
        overlay1
        overlay2
        subtext0
        subtext1
        text
        ;
      accents = v.accents;
      ansi = v.ansi;
    }) t.flavors;
  }) themes;

  # ---------------------------------------------------------------------------
  # Default selection: what a fresh build themes terminals/desktop to. The
  # runtime CLI (scripts/theme) overrides these files when you run ./theme ...
  # ---------------------------------------------------------------------------
  defaultTheme = "catppuccin";
  defaultFlavor = "macchiato";
  defaultAccent = "mauve";

  selectedTheme = themes.${defaultTheme};
  selectedFlavor = selectedTheme.flavors.${defaultFlavor};
  r = resolve selectedFlavor defaultAccent;

  h = v: "#${v}";

  # --- kitty runtime theme file ----------------------------------------------
  kittyTheme = ''
    # Generated by modules/config/colors (default) / scripts/theme (runtime).
    # Theme: ${defaultTheme} / ${defaultFlavor} / ${defaultAccent}
    background ${h r.crust}
    foreground ${h r.text}
    selection_background ${h r.accent}
    selection_foreground ${h r.crust}
    url_color ${h r.accent}
    active_border_color ${h r.accent}
    inactive_border_color ${h r.overlay1}
    active_tab_foreground ${h r.crust}
    active_tab_background ${h r.accent}
    inactive_tab_foreground ${h r.text}
    inactive_tab_background ${h r.mantle}
    tab_bar_background ${h r.crust}
    ${lib.concatStringsSep "\n" (lib.imap0 (i: cV: "color${toString i} ${h cV}") r.ansi)}
  '';

  # --- alacritty runtime theme file (a [colors] fragment to import) ----------
  alacrittyTheme = ''
    # Generated by modules/config/colors (default) / scripts/theme (runtime).
    # Theme: ${defaultTheme} / ${defaultFlavor} / ${defaultAccent}
    [colors]
    primary = { background = "${h r.crust}", foreground = "${h r.text}" }
    cursor = { text = "${h r.crust}", cursor = "${h r.accent}" }
    selection = { text = "${h r.crust}", background = "${h r.accent}" }

    [colors.normal]
    black   = "${h (builtins.elemAt r.ansi 0)}"
    red     = "${h (builtins.elemAt r.ansi 1)}"
    green   = "${h (builtins.elemAt r.ansi 2)}"
    yellow  = "${h (builtins.elemAt r.ansi 3)}"
    blue    = "${h (builtins.elemAt r.ansi 4)}"
    magenta = "${h (builtins.elemAt r.ansi 5)}"
    cyan    = "${h (builtins.elemAt r.ansi 6)}"
    white   = "${h (builtins.elemAt r.ansi 7)}"

    [colors.bright]
    black   = "${h (builtins.elemAt r.ansi 8)}"
    red     = "${h (builtins.elemAt r.ansi 9)}"
    green   = "${h (builtins.elemAt r.ansi 10)}"
    yellow  = "${h (builtins.elemAt r.ansi 11)}"
    blue    = "${h (builtins.elemAt r.ansi 12)}"
    magenta = "${h (builtins.elemAt r.ansi 13)}"
    cyan    = "${h (builtins.elemAt r.ansi 14)}"
    white   = "${h (builtins.elemAt r.ansi 15)}"
  '';

  # --- wezterm runtime theme file (lua fragment that defines the scheme) -----
  # Returns a table merged into the wezterm config via dofile in extraConfig.
  weztermTheme =
    let
      a = r.ansi;
      luaList = lib.concatMapStringsSep ", " (cV: "\"${h cV}\"");
      ansi = luaList (lib.sublist 0 8 a);
      brights = luaList (lib.sublist 8 8 a);
    in
    ''
      -- Generated by modules/config/colors (default) / scripts/theme (runtime).
      -- Theme: ${defaultTheme} / ${defaultFlavor} / ${defaultAccent}
      return {
        colors = {
          foreground = "${h r.text}",
          background = "${h r.crust}",
          cursor_bg = "${h r.accent}",
          cursor_fg = "${h r.crust}",
          cursor_border = "${h r.accent}",
          selection_fg = "${h r.crust}",
          selection_bg = "${h r.accent}",
          ansi = { ${ansi} },
          brights = { ${brights} },
        },
      }
    '';

  # --- tmux runtime theme file (theme-agnostic raw colors) --------------------
  tmuxTheme =
    let
      c = v: "#${v}";
      # resolved roles
      bb = builtins.elemAt r.ansi 0; # black
      rd = builtins.elemAt r.ansi 1; # red
      yw = builtins.elemAt r.ansi 3; # yellow
      # on-accent: contrast text for accent-filled elements (use the base bg).
      onAccent = r.base;
    in
    ''
      # Generated by modules/config/colors (default) / scripts/theme (runtime).
      # Theme: ${defaultTheme} / ${defaultFlavor} / ${defaultAccent}
      set -g status-style "bg=${c r.crust},fg=${c r.text}"
      set -g status-left-style "bg=${c r.accent},fg=${c onAccent}"
      set -g status-right-style "bg=${c r.surface0},fg=${c r.subtext0}"
      set -g window-status-style "bg=${c r.surface0},fg=${c r.subtext0}"
      set -g window-status-current-style "bg=${c r.accent},fg=${c onAccent}"
      set -g window-status-activity-style "bg=${c r.surface1},fg=${c yw}"
      set -g window-status-bell-style "bg=${c r.surface1},fg=${c rd}"
      set -g pane-border-style "fg=${c r.overlay0}"
      set -g pane-active-border-style "fg=${c r.accent}"
      set -g message-style "bg=${c r.surface0},fg=${c r.text}"
      set -g message-command-style "bg=${c r.accent},fg=${c onAccent}"
      set -g mode-style "bg=${c r.accent},fg=${c onAccent}"
      set -g display-panes-colour "${c r.accent}"
      set -g display-panes-active-colour "${c r.text}"
      setw -g window-status-format " #I:#W "
      setw -g window-status-current-format " #I:#W "
    '';

  # --- hyprland runtime theme file (lua fragment, dofiled by extraConfig) -----
  # Returns { active_border, inactive_border } in 0xRRGGBB format. colors.nix
  # (extraConfig) dofiles this on every hyprctl reload so switching needs no
  # rebuild.
  hyprlandTheme =
    let
      x = v: "0x${v}";
    in
    ''
      -- Generated by modules/config/colors (default) / scripts/theme (runtime).
      -- Theme: ${defaultTheme} / ${defaultFlavor} / ${defaultAccent}
      return {
        active_border = "${x r.accent}",
        inactive_border = "${x r.overlay1}",
      }
    '';
in
{
  options.colors = {
    # Full theme database (theme -> title + flavors -> roles + accents).
    themes = mkOption {
      type = types.attrs;
      readOnly = true;
      description = "Generic theme database exposed for build-time consumers";
    };
    # Selected default theme (used only for generating the build-time runtime
    # files; the CLI switches themes at runtime, no rebuild needed).
    theme = mkOption {
      type = types.str;
      default = defaultTheme;
    };
    flavor = mkOption {
      type = types.str;
      default = defaultFlavor;
    };
    accent = mkOption {
      type = types.str;
      default = defaultAccent;
    };
    # Resolved default roles for any build-time consumer.
    active = mkOption {
      type = types.attrs;
      readOnly = true;
    };
  };

  config = {
    colors.themes = themesJSON;
    colors.active = r;

    # Machine-readable themes DB for the runtime script (scripts/theme).
    home.file.".local/share/theme-switcher/themes.json" = {
      text = builtins.toJSON themesJSON;
    };

    # Persistent record of the default selection.
    home.file.".local/share/theme-switcher/default" = {
      text = "${defaultTheme} ${defaultFlavor} ${defaultAccent}\n";
    };

    # Initial runtime theme files so the four terminals work out of the box.
    # scripts/theme overwrites these (no rebuild) on ./theme set ...
    home.file.".config/theme-switcher/kitty-theme.conf" = {
      text = kittyTheme;
      force = true;
    };
    home.file.".config/theme-switcher/alacritty-theme.toml" = {
      text = alacrittyTheme;
      force = true;
    };
    home.file.".config/theme-switcher/wezterm-theme.lua" = {
      text = weztermTheme;
      force = true;
    };
    home.file.".config/theme-switcher/tmux-theme.conf" = {
      text = tmuxTheme;
      force = true;
    };
    home.file.".config/theme-switcher/hyprland-theme.lua" = {
      text = hyprlandTheme;
      force = true;
    };

    # The runtime theme files above arrive as read-only store symlinks, but
    # scripts/theme must overwrite them to switch themes. Materialize each into
    # a real writable file on first activation (following the store symlink).
    # On later switches they are already real files, so CLI edits persist.
    home.activation.themeSwitcherWritable =
      lib.hm.dag.entryAfter
        [
          "writeBoundary"
        ]
        ''
          $DRY_RUN_CMD install -d -m 0755 "$HOME/.config/theme-switcher"
          for f in kitty-theme.conf alacritty-theme.toml wezterm-theme.lua tmux-theme.conf hyprland-theme.lua; do
            tgt="$HOME/.config/theme-switcher/$f"
            if [[ -L "$tgt" ]]; then
              $DRY_RUN_CMD cp -fL "$tgt" "$tgt.tmp" && $DRY_RUN_CMD mv -f "$tgt.tmp" "$tgt"
            fi
          done
        '';
  };
}
