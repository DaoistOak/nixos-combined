# Shared, side-effect-free theme database + resolvers.
#
# Consumed by:
#   modules/config/colors/default.nix  -> runtime terminal files + colors.* options
#   modules/config/theme/default.nix   -> home-manager Stylix (GTK/KDE/Qt/..)
#   nixos/configuration.nix            -> system Stylix (console/plymouth)
#   home-manager/home.nix              -> the catppuccin HM module selection
#
# Take { lib } as the only argument so a plain `import` works from both the
# home-manager and NixOS module trees.

{ lib }:

let
  # ---------------------------------------------------------------------------
  # Generic theme database.
  #
  # Every theme exposes the same shape:
  #   <theme> = {
  #     title    = "Human readable name";
  #     flavors  = {
  #       <variant> = {
  #         title    = "Human readable variant name";
  #         polarity = "dark" | "light";
  #         roles    = { ... };   # normalized role colors (raw hex, no '#')
  #         accents  = { <accent> = "hex"; ... };
  #         ansi     = [ 16 colors ];
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

  isHex = s: (builtins.match "[#]?[0-9a-fA-F]{6}" s) != null;

  # Pure-builtin string helpers (kept dependency-free on purpose: { lib } is
  # still accepted for call-site compatibility, but the logic below must not
  # rely on any lib.* attribute).
  stripHash = s:
    if builtins.substring 0 1 s == "#" then
      builtins.substring 1 (-1) s
    else
      s;

  # Split on single spaces, drop empties and newlines. Handles the persisted
  # "theme flavor accent\n" selection file. (builtins.split yields the
  # separators themselves as inert `[ ]` entries — drop anything non-string.)
  words = s:
    builtins.filter (
      x: builtins.typeOf x == "string" && x != ""
    ) (builtins.split " " (builtins.replaceStrings [ "\n" ] [ "" ] s));

  # Resolve a raw variant slot into normalized roles given a chosen accent name.
  # Returns raw hex (no '#'). Supports custom hex accents ("#aabbcc" / "aabbcc")
  # in addition to named accents from the palette.
  resolve =
    v: accent:
    let
      stripped = stripHash accent;
      resolvedAccent =
        if v.accents ? ${accent} then
          v.accents.${accent}
        else if isHex accent then
          stripped
        else
          v.accents.default or (builtins.head (builtins.attrValues v.accents));
    in
    {
      polarity = v.polarity;
      title = v.title;
      accentName = if v.accents ? ${accent} then accent else stripped;
      accent = resolvedAccent;
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
      accents = v.accents;
    };

  # Derive a base16 scheme (attrset, matching the base16 standard + the
  # cjpais/base16-catppuccin slot conventions) from resolved roles. Stylix
  # accepts this directly as `stylix.base16Scheme`, so GTK/KDE/Qt/.. follow the
  # active theme AND accent with no extra yaml file involved.
  toBase16 =
    r:
    let
      h = v: "#${v}";
      a = name: fallback: r.accents.${name} or fallback;
      ansi = n: builtins.elemAt r.ansi n;
    in
    {
      name = r.name;
      base00 = h r.base; # main background
      base01 = h r.surface0;
      base02 = h r.surface1;
      base03 = h r.overlay0;
      base04 = h r.subtext0;
      base05 = h r.text;
      base06 = h (a "rosewater" (ansi 7));
      base07 = h (a "lavender" (ansi 15));
      base08 = h (a "red" (ansi 1));
      base09 = h (a "peach" (a "orange" (ansi 3)));
      base0A = h (a "yellow" (ansi 3));
      base0B = h (a "green" (ansi 2));
      base0C = h (a "teal" (a "cyan" (ansi 6)));
      base0D = h r.accent; # Stylix' primary accent (matches the old override)
      base0E = h (a "mauve" (a "purple" (ansi 5)));
      base0F = h (a "flamingo" (a "maroon" (ansi 9)));
    };

  # Read the persisted theme selection ("theme flavor accent") from a repo
  # file. Any unknown/missing field falls back to the defaults so a stale or
  # hand-edited file can never break the build.
  readSelection =
    selFile:
    let
      defaults = {
        theme = "catppuccin";
        flavor = "macchiato";
        accent = "mauve";
      };
      raw = if builtins.pathExists selFile then builtins.readFile selFile else "";
      parts = words raw;
      part =
        n:
        if builtins.length parts > n then
          builtins.elemAt parts n
        else
          "";
      themeName =
        let t = part 0; in
        if t != "" && builtins.hasAttr t themes then t else defaults.theme;
      flavorName =
        let f = part 1; in
        if f != "" && builtins.hasAttr f themes.${themeName}.flavors then
          f
        else
          defaults.flavor;
      accentsOf = themes.${themeName}.flavors.${flavorName}.accents;
      accentName =
        let a = part 2; in
        if a != "" && (builtins.hasAttr a accentsOf || isHex a) then
          a
        else
          defaults.accent;
      flavor = themes.${themeName}.flavors.${flavorName};
      # Override selective base16-scheme `name` is derived from the DB keys:
      # no builtin promotes to lowercase, but the theme/flavor keys already are.
      name =
        if flavorName == "default" then
          themeName
        else
          "${themeName}-${flavorName}";
      r =
        (resolve flavor accentName) // {
          inherit name;
        };
    in
    {
      inherit themeName flavorName accentName name flavor r;
    };
in
{
  inherit themes resolve toBase16 readSelection;
}