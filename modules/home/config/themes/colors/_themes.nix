# Shared, side-effect-free theme database + resolvers.
# Consumed by: colors, theme (Stylix), nixos (Stylix console/plymouth),
# home-manager home.nix (catppuccin HM module).
# Adding a new theme = append an attrset with the same shape; the normalized
# `roles` keep the runtime switcher theme-agnostic.
#
# Normalized roles (raw hex, no '#'): bg, fg, base, mantle, crust,
# surface0..2, overlay0..2, subtext0..1, text, accent, ansi (16 colors).

{ lib }:

let
  themes = {
    catppuccin = {
      title = "Catppuccin";
      flavors = rec {
        latte = {
          title = "Latte";
          polarity = "light";
          ghostty = "Catppuccin Latte";
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
          ghostty = "Catppuccin Frappe";
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
          ghostty = "Catppuccin Macchiato";
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
          ghostty = "Catppuccin Mocha";
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
          ghostty = "Dracula";
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
            rosewater = "e3d5f4";
            lavender = "d3b9f6";
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

    TokyoNight = {
      title = "TokyoNight";
      flavors = {
        night = {
          title = "Night";
          polarity = "dark";
          ghostty = "TokyoNight Night";
          base = "1a1b26";
          mantle = "191a24";
          crust = "181923";
          surface0 = "2c2e3d";
          surface1 = "3f4254";
          surface2 = "51556b";
          overlay0 = "646982";
          overlay1 = "767c99";
          overlay2 = "8990b0";
          subtext0 = "9ba3c7";
          subtext1 = "aeb7de";
          text = "c0caf5";
          accents = {
            rosewater = "a8bcf6";
            lavender = "95b1f6";
            red = "f7768e";
            maroon = "ff899d";
            peach = "ff9e64";
            orange = "ff9e64";
            yellow = "e0af68";
            green = "9ece6a";
            teal = "7dcfff";
            cyan = "a4daff";
            blue = "7aa2f7";
            sapphire = "8db0ff";
            purple = "bb9af7";
            mauve = "c7a9ff";
            default = "7aa2f7";
          };
          ansi = [
            "15161e"
            "f7768e"
            "9ece6a"
            "e0af68"
            "7aa2f7"
            "bb9af7"
            "7dcfff"
            "a9b1d6"
            "414868"
            "ff899d"
            "9fe044"
            "faba4a"
            "8db0ff"
            "c7a9ff"
            "a4daff"
            "c0caf5"
          ];
        };
        storm = {
          title = "Storm";
          polarity = "dark";
          ghostty = "TokyoNight Storm";
          base = "24283b";
          mantle = "232639";
          crust = "212536";
          surface0 = "353a4f";
          surface1 = "474c64";
          surface2 = "585e79";
          overlay0 = "69708e";
          overlay1 = "7b82a2";
          overlay2 = "8c94b7";
          subtext0 = "9da6cc";
          subtext1 = "afb8e1";
          text = "c0caf5";
          accents = {
            rosewater = "a8bcf6";
            lavender = "95b1f6";
            red = "f7768e";
            maroon = "ff899d";
            peach = "ff9e64";
            orange = "ff9e64";
            yellow = "e0af68";
            green = "9ece6a";
            teal = "7dcfff";
            cyan = "a4daff";
            blue = "7aa2f7";
            sapphire = "8db0ff";
            purple = "bb9af7";
            mauve = "c7a9ff";
            default = "7aa2f7";
          };
          ansi = [
            "1d202f"
            "f7768e"
            "9ece6a"
            "e0af68"
            "7aa2f7"
            "bb9af7"
            "7dcfff"
            "a9b1d6"
            "414868"
            "ff899d"
            "9fe044"
            "faba4a"
            "8db0ff"
            "c7a9ff"
            "a4daff"
            "c0caf5"
          ];
        };
        moon = {
          title = "Moon";
          polarity = "dark";
          ghostty = "TokyoNight Moon";
          base = "222436";
          mantle = "212334";
          crust = "1f2132";
          surface0 = "34374b";
          surface1 = "474b61";
          surface2 = "595e75";
          overlay0 = "6c728b";
          overlay1 = "7e85a0";
          overlay2 = "9199b6";
          subtext0 = "a3acca";
          subtext1 = "b6c0e0";
          text = "c8d3f5";
          accents = {
            rosewater = "b0c5f8";
            lavender = "9dbafb";
            red = "ff757f";
            maroon = "ff8d94";
            peach = "ff966c";
            orange = "ff966c";
            yellow = "ffc777";
            green = "c3e88d";
            teal = "86e1fc";
            cyan = "b2ebff";
            blue = "82aaff";
            sapphire = "9ab8ff";
            purple = "c099ff";
            mauve = "caabff";
            default = "82aaff";
          };
          ansi = [
            "1b1d2b"
            "ff757f"
            "c3e88d"
            "ffc777"
            "82aaff"
            "c099ff"
            "86e1fc"
            "828bb8"
            "444a73"
            "ff8d94"
            "c7fb6d"
            "ffd8ab"
            "9ab8ff"
            "caabff"
            "b2ebff"
            "c8d3f5"
          ];
        };
        day = {
          title = "Day";
          polarity = "light";
          ghostty = "TokyoNight Day";
          base = "e1e2e7";
          mantle = "d9dce3";
          crust = "d1d4df";
          surface0 = "c2c7d7";
          surface1 = "b2bacf";
          surface2 = "a3adc7";
          overlay0 = "94a0c0";
          overlay1 = "8493b7";
          overlay2 = "7486b0";
          subtext0 = "6579a8";
          subtext1 = "566ca0";
          text = "3760bf";
          accents = {
            rosewater = "3469cc";
            lavender = "3270d6";
            red = "f52a65";
            maroon = "ff4774";
            peach = "b15c00";
            orange = "b15c00";
            yellow = "8c6c3e";
            green = "587539";
            teal = "007197";
            cyan = "007ea8";
            blue = "2e7de9";
            sapphire = "358aff";
            purple = "9854f1";
            mauve = "a463ff";
            default = "2e7de9";
          };
          ansi = [
            "b4b5b9"
            "f52a65"
            "587539"
            "8c6c3e"
            "2e7de9"
            "9854f1"
            "007197"
            "6172b0"
            "a1a6c5"
            "ff4774"
            "5c8524"
            "a27629"
            "358aff"
            "a463ff"
            "007ea8"
            "3760bf"
          ];
        };
      };
    };
    Gruvbox = {
      title = "Gruvbox";
      flavors = {
        dark = {
          title = "Dark";
          polarity = "dark";
          ghostty = "Gruvbox Dark";
          base = "282828";
          mantle = "262626";
          crust = "252525";
          surface0 = "3d3c37";
          surface1 = "535047";
          surface2 = "696356";
          overlay0 = "7f7865";
          overlay1 = "948b75";
          overlay2 = "aaa084";
          subtext0 = "c0b393";
          subtext1 = "d6c7a3";
          text = "ebdbb2";
          accents = {
            rosewater = "c7c8a9";
            lavender = "abbaa2";
            red = "cc241d";
            maroon = "fb4934";
            peach = "fe8019";
            orange = "fe8019";
            yellow = "d79921";
            green = "98971a";
            teal = "689d6a";
            cyan = "8ec07c";
            blue = "458588";
            sapphire = "83a598";
            purple = "b16286";
            mauve = "d3869b";
            default = "83a598";
          };
          ansi = [
            "3c3836"
            "cc241d"
            "98971a"
            "d79921"
            "458588"
            "b16286"
            "689d6a"
            "a89984"
            "928374"
            "fb4934"
            "b8bb26"
            "fabd2f"
            "83a598"
            "d3869b"
            "8ec07c"
            "fbf1c7"
          ];
        };
        light = {
          title = "Light";
          polarity = "light";
          ghostty = "Gruvbox Light";
          base = "fbf1c7";
          mantle = "f2e8c0";
          crust = "e7deb8";
          surface0 = "d4cbaa";
          surface1 = "c1b99b";
          surface2 = "aea78d";
          overlay0 = "9b947f";
          overlay1 = "878170";
          overlay2 = "746f62";
          subtext0 = "615d54";
          subtext1 = "4e4b45";
          text = "3c3836";
          accents = {
            rosewater = "2c464a";
            lavender = "1f515a";
            red = "cc241d";
            maroon = "9d0006";
            peach = "af3a03";
            orange = "af3a03";
            yellow = "d79921";
            green = "98971a";
            teal = "689d6a";
            cyan = "427b58";
            blue = "458588";
            sapphire = "076678";
            purple = "b16286";
            mauve = "8f3f71";
            default = "076678";
          };
          ansi = [
            "ebdbb2"
            "cc241d"
            "98971a"
            "d79921"
            "458588"
            "b16286"
            "689d6a"
            "7c6f64"
            "928374"
            "9d0006"
            "79740e"
            "b57614"
            "076678"
            "8f3f71"
            "427b58"
            "282828"
          ];
        };
        material-dark = {
          title = "Material Dark";
          polarity = "dark";
          ghostty = "Gruvbox Material Dark";
          base = "282828";
          mantle = "262626";
          crust = "252525";
          surface0 = "3d3c37";
          surface1 = "535047";
          surface2 = "696356";
          overlay0 = "7f7865";
          overlay1 = "948b75";
          overlay2 = "aaa084";
          subtext0 = "c0b393";
          subtext1 = "d6c7a3";
          text = "ebdbb2";
          accents = {
            rosewater = "c7c8a9";
            lavender = "abbaa2";
            red = "cc241d";
            maroon = "fb4934";
            peach = "fe8019";
            orange = "fe8019";
            yellow = "d79921";
            green = "98971a";
            teal = "689d6a";
            cyan = "8ec07c";
            blue = "458588";
            sapphire = "83a598";
            purple = "b16286";
            mauve = "d3869b";
            default = "83a598";
          };
          ansi = [
            "3c3836"
            "cc241d"
            "98971a"
            "d79921"
            "458588"
            "b16286"
            "689d6a"
            "a89984"
            "928374"
            "fb4934"
            "b8bb26"
            "fabd2f"
            "83a598"
            "d3869b"
            "8ec07c"
            "fbf1c7"
          ];
        };
        material-light = {
          title = "Material Light";
          polarity = "light";
          ghostty = "Gruvbox Material Light";
          base = "fbf1c7";
          mantle = "f2e8c0";
          crust = "e7deb8";
          surface0 = "d4cbaa";
          surface1 = "c1b99b";
          surface2 = "aea78d";
          overlay0 = "9b947f";
          overlay1 = "878170";
          overlay2 = "746f62";
          subtext0 = "615d54";
          subtext1 = "4e4b45";
          text = "3c3836";
          accents = {
            rosewater = "2c464a";
            lavender = "1f515a";
            red = "cc241d";
            maroon = "9d0006";
            peach = "af3a03";
            orange = "af3a03";
            yellow = "d79921";
            green = "98971a";
            teal = "689d6a";
            cyan = "427b58";
            blue = "458588";
            sapphire = "076678";
            purple = "b16286";
            mauve = "8f3f71";
            default = "076678";
          };
          ansi = [
            "ebdbb2"
            "cc241d"
            "98971a"
            "d79921"
            "458588"
            "b16286"
            "689d6a"
            "7c6f64"
            "928374"
            "9d0006"
            "79740e"
            "b57614"
            "076678"
            "8f3f71"
            "427b58"
            "282828"
          ];
        };
      };
    };
    Nord = {
      title = "Nord";
      flavors = {
        dark = {
          title = "Dark";
          polarity = "dark";
          ghostty = "Nord";
          base = "2e3440";
          mantle = "2c323d";
          crust = "2a303b";
          surface0 = "414753";
          surface1 = "545a66";
          surface2 = "666c78";
          overlay0 = "7a808b";
          overlay1 = "8c929e";
          overlay2 = "a0a6b1";
          subtext0 = "b2b8c3";
          subtext1 = "c5cbd6";
          text = "d8dee9";
          accents = {
            rosewater = "bcd4e0";
            lavender = "a6cbda";
            red = "bf616a";
            maroon = "bf616a";
            peach = "d08770";
            orange = "d08770";
            yellow = "ebcb8b";
            green = "a3be8c";
            teal = "88c0d0";
            cyan = "8fbcbb";
            blue = "81a1c1";
            sapphire = "5e81ac";
            purple = "b48ead";
            mauve = "b48ead";
            default = "88c0d0";
          };
          ansi = [
            "3b4252"
            "bf616a"
            "a3be8c"
            "ebcb8b"
            "81a1c1"
            "b48ead"
            "88c0d0"
            "e5e9f0"
            "4c566a"
            "bf616a"
            "a3be8c"
            "d08770"
            "5e81ac"
            "b48ead"
            "8fbcbb"
            "eceff4"
          ];
        };
        light = {
          title = "Light";
          polarity = "light";
          ghostty = "Nord Light";
          base = "eceff4";
          mantle = "e3e6eb";
          crust = "d8dbe1";
          surface0 = "c6c9ce";
          surface1 = "b3b6bc";
          surface2 = "a1a4aa";
          overlay0 = "8e9197";
          overlay1 = "7b7e84";
          overlay2 = "686b72";
          subtext0 = "555960";
          subtext1 = "43464d";
          text = "2e3440";
          accents = {
            rosewater = "3c4b60";
            lavender = "485e7b";
            red = "bf616a";
            maroon = "bf616a";
            peach = "d08770";
            orange = "d08770";
            yellow = "ebcb8b";
            green = "a3be8c";
            teal = "88c0d0";
            cyan = "8fbcbb";
            blue = "81a1c1";
            sapphire = "5e81ac";
            purple = "b48ead";
            mauve = "b48ead";
            default = "5e81ac";
          };
          ansi = [
            "3b4252"
            "bf616a"
            "a3be8c"
            "ebcb8b"
            "81a1c1"
            "b48ead"
            "88c0d0"
            "e5e9f0"
            "4c566a"
            "bf616a"
            "a3be8c"
            "d08770"
            "5e81ac"
            "b48ead"
            "8fbcbb"
            "2e3440"
          ];
        };
        wave = {
          title = "Wave";
          polarity = "dark";
          ghostty = "Nord Wave";
          base = "2e3440";
          mantle = "2c323d";
          crust = "2a303b";
          surface0 = "414753";
          surface1 = "545a66";
          surface2 = "666c78";
          overlay0 = "7a808b";
          overlay1 = "8c929e";
          overlay2 = "a0a6b1";
          subtext0 = "b2b8c3";
          subtext1 = "c5cbd6";
          text = "d8dee9";
          accents = {
            rosewater = "bcd4e0";
            lavender = "a6cbda";
            red = "bf616a";
            maroon = "bf616a";
            peach = "d08770";
            orange = "d08770";
            yellow = "ebcb8b";
            green = "a3be8c";
            teal = "88c0d0";
            cyan = "8fbcbb";
            blue = "81a1c1";
            sapphire = "5e81ac";
            purple = "b48ead";
            mauve = "b48ead";
            default = "88c0d0";
          };
          ansi = [
            "3b4252"
            "bf616a"
            "a3be8c"
            "ebcb8b"
            "81a1c1"
            "b48ead"
            "88c0d0"
            "e5e9f0"
            "4c566a"
            "bf616a"
            "a3be8c"
            "d08770"
            "5e81ac"
            "b48ead"
            "8fbcbb"
            "eceff4"
          ];
        };
      };
    };
    RosePine = {
      title = "RosePine";
      flavors = {
        main = {
          title = "Main";
          polarity = "dark";
          ghostty = "Rose Pine";
          base = "191724";
          mantle = "181623";
          crust = "171521";
          surface0 = "2f2d3b";
          surface1 = "454352";
          surface2 = "5b5969";
          overlay0 = "727081";
          overlay1 = "878597";
          overlay2 = "9e9caf";
          subtext0 = "b4b2c6";
          subtext1 = "cac8dd";
          text = "e0def4";
          accents = {
            rosewater = "e4d2e0";
            lavender = "e7c9d0";
            red = "eb6f92";
            maroon = "eb6f92";
            peach = "ebbcba";
            orange = "f6c177";
            yellow = "f6c177";
            green = "31748f";
            teal = "ebbcba";
            cyan = "ebbcba";
            blue = "9ccfd8";
            sapphire = "9ccfd8";
            purple = "c4a7e7";
            mauve = "c4a7e7";
            default = "ebbcba";
          };
          ansi = [
            "26233a"
            "eb6f92"
            "31748f"
            "f6c177"
            "9ccfd8"
            "c4a7e7"
            "ebbcba"
            "e0def4"
            "6e6a86"
            "eb6f92"
            "31748f"
            "f6c177"
            "9ccfd8"
            "c4a7e7"
            "ebbcba"
            "e0def4"
          ];
        };
        moon = {
          title = "Moon";
          polarity = "dark";
          ghostty = "Rose Pine Moon";
          base = "232136";
          mantle = "222034";
          crust = "201e32";
          surface0 = "38364b";
          surface1 = "4d4b60";
          surface2 = "626075";
          overlay0 = "77758b";
          overlay1 = "8c8a9f";
          overlay2 = "a19fb5";
          subtext0 = "b6b4ca";
          subtext1 = "cbc9df";
          text = "e0def4";
          accents = {
            rosewater = "c8d9ea";
            lavender = "b6d5e3";
            red = "eb6f92";
            maroon = "eb6f92";
            peach = "ea9a97";
            orange = "f6c177";
            yellow = "f6c177";
            green = "3e8fb0";
            teal = "ea9a97";
            cyan = "ea9a97";
            blue = "9ccfd8";
            sapphire = "9ccfd8";
            purple = "c4a7e7";
            mauve = "c4a7e7";
            default = "9ccfd8";
          };
          ansi = [
            "393552"
            "eb6f92"
            "3e8fb0"
            "f6c177"
            "9ccfd8"
            "c4a7e7"
            "ea9a97"
            "e0def4"
            "6e6a86"
            "eb6f92"
            "3e8fb0"
            "f6c177"
            "9ccfd8"
            "c4a7e7"
            "ea9a97"
            "e0def4"
          ];
        };
        dawn = {
          title = "Dawn";
          polarity = "light";
          ghostty = "Rose Pine Dawn";
          base = "faf4ed";
          mantle = "f2ece7";
          crust = "e9e3df";
          surface0 = "d9d3d2";
          surface1 = "c8c3c6";
          surface2 = "b8b3b9";
          overlay0 = "a8a4ac";
          overlay1 = "97939e";
          overlay2 = "878392";
          subtext0 = "777385";
          subtext1 = "676378";
          text = "575279";
          accents = {
            rosewater = "576684";
            lavender = "56768e";
            red = "b4637a";
            maroon = "b4637a";
            peach = "d7827e";
            orange = "ea9d34";
            yellow = "ea9d34";
            green = "286983";
            teal = "d7827e";
            cyan = "d7827e";
            blue = "56949f";
            sapphire = "56949f";
            purple = "907aa9";
            mauve = "907aa9";
            default = "56949f";
          };
          ansi = [
            "f2e9e1"
            "b4637a"
            "286983"
            "ea9d34"
            "56949f"
            "907aa9"
            "d7827e"
            "575279"
            "9893a5"
            "b4637a"
            "286983"
            "ea9d34"
            "56949f"
            "907aa9"
            "d7827e"
            "575279"
          ];
        };
      };
    };
    Everforest = {
      title = "Everforest";
      flavors = {
        dark = {
          title = "Dark";
          polarity = "dark";
          ghostty = "Everforest Dark Hard";
          base = "2d353b";
          mantle = "2b3339";
          crust = "293136";
          surface0 = "3f4547";
          surface1 = "525554";
          surface2 = "646560";
          overlay0 = "77766c";
          overlay1 = "898579";
          overlay2 = "9c9685";
          subtext0 = "aea691";
          subtext1 = "c1b69e";
          text = "d3c6aa";
          accents = {
            rosewater = "c4c49b";
            lavender = "b8c290";
            red = "e67e80";
            maroon = "e67e80";
            peach = "e6985e";
            orange = "e6985e";
            yellow = "dbbc7f";
            green = "a7c080";
            teal = "83c092";
            cyan = "83c092";
            blue = "7fbbb3";
            sapphire = "7fbbb3";
            purple = "d699b6";
            mauve = "d699b6";
            default = "a7c080";
          };
          ansi = [
            "343f44"
            "e67e80"
            "a7c080"
            "dbbc7f"
            "7fbbb3"
            "d699b6"
            "83c092"
            "859289"
            "868d80"
            "e67e80"
            "a7c080"
            "dbbc7f"
            "7fbbb3"
            "d699b6"
            "83c092"
            "9da9a0"
          ];
        };
        light = {
          title = "Light";
          polarity = "light";
          ghostty = "Everforest Light Med";
          base = "fdf6e3";
          mantle = "f5efdd";
          crust = "ede7d7";
          surface0 = "ddd9cb";
          surface1 = "cecbc0";
          surface2 = "bebdb4";
          overlay0 = "afafa8";
          overlay1 = "9fa19c";
          overlay2 = "8f9391";
          subtext0 = "808585";
          subtext1 = "707779";
          text = "5c6a72";
          accents = {
            rosewater = "52778b";
            lavender = "4981a0";
            red = "f85552";
            maroon = "e66868";
            peach = "f57d26";
            orange = "f57d26";
            yellow = "dfa000";
            green = "8da101";
            teal = "35a77c";
            cyan = "35a77c";
            blue = "3a94c5";
            sapphire = "3a94c5";
            purple = "df69ba";
            mauve = "df69ba";
            default = "3a94c5";
          };
          ansi = [
            "708089"
            "f85552"
            "8da101"
            "dfa000"
            "3a94c5"
            "df69ba"
            "35a77c"
            "939f91"
            "829181"
            "e66868"
            "93b259"
            "dfa000"
            "3a94c5"
            "df69ba"
            "35a77c"
            "a6b0a0"
          ];
        };
      };
    };
    Ayu = {
      title = "Ayu";
      flavors = {
        dark = {
          title = "Dark";
          polarity = "dark";
          ghostty = "Ayu";
          base = "0e1419";
          mantle = "0d1318";
          crust = "0d1217";
          surface0 = "262b2d";
          surface1 = "3e4242";
          surface2 = "555855";
          overlay0 = "6e6f6a";
          overlay1 = "85867e";
          overlay2 = "9e9d93";
          subtext0 = "b5b3a6";
          subtext1 = "cdcabb";
          text = "e5e1cf";
          accents = {
            rosewater = "a8cbd2";
            lavender = "78bbd5";
            red = "ff3333";
            maroon = "ff6565";
            peach = "ff8f40";
            orange = "ff8f40";
            yellow = "e6c446";
            green = "b8cc52";
            teal = "95e5cb";
            cyan = "c7fffc";
            blue = "36a3d9";
            sapphire = "68d4ff";
            purple = "f07078";
            mauve = "ffa3aa";
            default = "36a3d9";
          };
          ansi = [
            "000000"
            "ff3333"
            "b8cc52"
            "e6c446"
            "36a3d9"
            "f07078"
            "95e5cb"
            "ffffff"
            "323232"
            "ff6565"
            "e9fe83"
            "fff778"
            "68d4ff"
            "ffa3aa"
            "c7fffc"
            "ffffff"
          ];
        };
        mirage = {
          title = "Mirage";
          polarity = "dark";
          ghostty = "Ayu Mirage";
          base = "212733";
          mantle = "202531";
          crust = "1e242f";
          surface0 = "353a44";
          surface1 = "4a4e56";
          surface2 = "5e6166";
          overlay0 = "737578";
          overlay1 = "878989";
          overlay2 = "9c9d9b";
          subtext0 = "b0b0ab";
          subtext1 = "c5c4bd";
          text = "d9d7ce";
          accents = {
            rosewater = "b3d3dd";
            lavender = "96d0e9";
            red = "ed8274";
            maroon = "f28779";
            peach = "f28779";
            orange = "ff8f40";
            yellow = "fad07b";
            green = "a6cc70";
            teal = "90e1c6";
            cyan = "95e6cb";
            blue = "6dcbfa";
            sapphire = "73d0ff";
            purple = "cfbafa";
            mauve = "d4bfff";
            default = "6dcbfa";
          };
          ansi = [
            "191e2a"
            "ed8274"
            "a6cc70"
            "fad07b"
            "6dcbfa"
            "cfbafa"
            "90e1c6"
            "c7c7c7"
            "686868"
            "f28779"
            "bae67e"
            "ffd580"
            "73d0ff"
            "d4bfff"
            "95e6cb"
            "ffffff"
          ];
        };
        light = {
          title = "Light";
          polarity = "light";
          ghostty = "Ayu Light";
          base = "fafafa";
          mantle = "f2f3f3";
          crust = "eaeaeb";
          surface0 = "dadcdd";
          surface1 = "cbcdcf";
          surface2 = "bcbec1";
          overlay0 = "acb0b3";
          overlay1 = "9ca0a5";
          overlay2 = "8d9297";
          subtext0 = "7e8389";
          subtext1 = "6e747b";
          text = "5b6673";
          accents = {
            rosewater = "537992";
            lavender = "4d89ab";
            red = "ff3333";
            maroon = "ff6565";
            peach = "f28779";
            orange = "ff8f40";
            yellow = "f19618";
            green = "86b200";
            teal = "4cbe99";
            cyan = "7ff0cb";
            blue = "41a6d9";
            sapphire = "73d7ff";
            purple = "f07078";
            mauve = "ffa3aa";
            default = "41a6d9";
          };
          ansi = [
            "000000"
            "ff3333"
            "86b200"
            "f19618"
            "41a6d9"
            "f07078"
            "4cbe99"
            "ffffff"
            "323232"
            "ff6565"
            "b8e532"
            "ffc849"
            "73d7ff"
            "ffa3aa"
            "7ff0cb"
            "ffffff"
          ];
        };
      };
    };
    Kanagawa = {
      title = "Kanagawa";
      flavors = {
        wave = {
          title = "Wave";
          polarity = "dark";
          ghostty = "Kanagawa Wave";
          base = "1f1f28";
          mantle = "1e1e26";
          crust = "1d1d25";
          surface0 = "343338";
          surface1 = "494849";
          surface2 = "5e5c58";
          overlay0 = "737169";
          overlay1 = "888579";
          overlay2 = "9d9a8a";
          subtext0 = "b2ae99";
          subtext1 = "c7c3aa";
          text = "dcd7ba";
          accents = {
            rosewater = "bbc2c4";
            lavender = "a2b2cd";
            red = "c34043";
            maroon = "e82424";
            peach = "ffa066";
            orange = "ffa066";
            yellow = "c0a36e";
            green = "76946a";
            teal = "6a9589";
            cyan = "7aa89f";
            blue = "7e9cd8";
            sapphire = "7fb4ca";
            purple = "957fb8";
            mauve = "938aa9";
            default = "7e9cd8";
          };
          ansi = [
            "16161d"
            "c34043"
            "76946a"
            "c0a36e"
            "7e9cd8"
            "957fb8"
            "6a9589"
            "c8c093"
            "727169"
            "e82424"
            "98bb6c"
            "e6c384"
            "7fb4ca"
            "938aa9"
            "7aa89f"
            "dcd7ba"
          ];
        };
        dragon = {
          title = "Dragon";
          polarity = "dark";
          ghostty = "Kanagawa Dragon";
          base = "181616";
          mantle = "171515";
          crust = "161414";
          surface0 = "2b2a29";
          surface1 = "3f3e3d";
          surface2 = "515150";
          overlay0 = "656664";
          overlay1 = "787977";
          overlay2 = "8c8e8b";
          subtext0 = "9ea19e";
          subtext1 = "b2b5b2";
          text = "c5c9c5";
          accents = {
            rosewater = "b1bcbe";
            lavender = "a1b2b8";
            red = "c4746e";
            maroon = "e46876";
            peach = "b98d7b";
            orange = "b6927b";
            yellow = "c4b28a";
            green = "8a9a7b";
            teal = "8ea4a2";
            cyan = "7aa89f";
            blue = "8ba4b0";
            sapphire = "7fb4ca";
            purple = "a292a3";
            mauve = "938aa9";
            default = "8ba4b0";
          };
          ansi = [
            "0d0c0c"
            "c4746e"
            "8a9a7b"
            "c4b28a"
            "8ba4b0"
            "a292a3"
            "8ea4a2"
            "c8c093"
            "a6a69c"
            "e46876"
            "87a987"
            "e6c384"
            "7fb4ca"
            "938aa9"
            "7aa89f"
            "c5c9c5"
          ];
        };
        lotus = {
          title = "Lotus";
          polarity = "light";
          ghostty = "Kanagawa Lotus";
          base = "f2ecbc";
          mantle = "eae5b7";
          crust = "e1dcb2";
          surface0 = "d2cda9";
          surface1 = "c2bea0";
          surface2 = "b3af96";
          overlay0 = "a3a08d";
          overlay1 = "939083";
          overlay2 = "83817a";
          subtext0 = "747271";
          subtext1 = "646367";
          text = "545464";
          accents = {
            rosewater = "525a74";
            lavender = "506082";
            red = "c84053";
            maroon = "d7474b";
            peach = "cc6d00";
            orange = "cc6d00";
            yellow = "77713f";
            green = "6f894e";
            teal = "597b75";
            cyan = "5e857a";
            blue = "4d699b";
            sapphire = "6693bf";
            purple = "b35b79";
            mauve = "624c83";
            default = "4d699b";
          };
          ansi = [
            "1f1f28"
            "c84053"
            "6f894e"
            "77713f"
            "4d699b"
            "b35b79"
            "597b75"
            "545464"
            "8a8980"
            "d7474b"
            "6e915f"
            "836f4a"
            "6693bf"
            "624c83"
            "5e857a"
            "43436c"
          ];
        };
      };
    };
    OneDark = {
      title = "OneDark";
      flavors = {
        dark = {
          title = "Dark";
          polarity = "dark";
          ghostty = "Onenord";
          base = "282c34";
          mantle = "262a32";
          crust = "252830";
          surface0 = "363b43";
          surface1 = "454a53";
          surface2 = "535862";
          overlay0 = "626872";
          overlay1 = "717681";
          overlay2 = "808691";
          subtext0 = "8e94a0";
          subtext1 = "9da3b0";
          text = "abb2bf";
          accents = {
            rosewater = "91b1d0";
            lavender = "7db0dd";
            red = "e06c75";
            maroon = "be5046";
            peach = "d19a66";
            orange = "d19a66";
            yellow = "d19a66";
            green = "98c379";
            teal = "56b6c2";
            cyan = "4cd1e0";
            blue = "61afef";
            sapphire = "4dc4ff";
            purple = "c678dd";
            mauve = "de73ff";
            default = "61afef";
          };
          ansi = [
            "3f4451"
            "e06c75"
            "98c379"
            "d19a66"
            "61afef"
            "c678dd"
            "56b6c2"
            "d7dae0"
            "4f5666"
            "be5046"
            "a5e075"
            "e5c07b"
            "4dc4ff"
            "de73ff"
            "4cd1e0"
            "e6e6e6"
          ];
        };
        light = {
          title = "Light";
          polarity = "light";
          ghostty = "Onenord Light";
          base = "fafafa";
          mantle = "f1f1f1";
          crust = "e6e6e6";
          surface0 = "d3d3d4";
          surface1 = "bfc0c1";
          surface2 = "acadaf";
          overlay0 = "999a9c";
          overlay1 = "858689";
          overlay2 = "727376";
          subtext0 = "5f6064";
          subtext1 = "4c4d51";
          text = "383a42";
          accents = {
            rosewater = "285067";
            lavender = "1a6385";
            red = "e45649";
            maroon = "e06c75";
            peach = "e45649";
            orange = "c18401";
            yellow = "c18401";
            green = "50a14f";
            teal = "0997b3";
            cyan = "56b6c2";
            blue = "0184bc";
            sapphire = "56b6c2";
            purple = "a626a4";
            mauve = "c678dd";
            default = "0184bc";
          };
          ansi = [
            "383a42"
            "e45649"
            "50a14f"
            "c18401"
            "0184bc"
            "a626a4"
            "0997b3"
            "fafafa"
            "a0a1a7"
            "e06c75"
            "98c379"
            "e5c07b"
            "56b6c2"
            "c678dd"
            "56b6c2"
            "383a42"
          ];
        };
      };
    };
    Material = {
      title = "Material";
      flavors = {
        darker = {
          title = "Darker";
          polarity = "dark";
          ghostty = "Material Darker";
          base = "212121";
          mantle = "202020";
          crust = "1e1e1e";
          surface0 = "383939";
          surface1 = "4f5353";
          surface2 = "656b6b";
          overlay0 = "7d8484";
          overlay1 = "939c9c";
          overlay2 = "abb5b5";
          subtext0 = "c1cdcd";
          subtext1 = "d8e7e7";
          text = "efffff";
          accents = {
            rosewater = "c9e1ff";
            lavender = "abcaff";
            red = "ff5370";
            maroon = "ff5370";
            peach = "f78c6c";
            orange = "f78c6c";
            yellow = "ffcb6b";
            green = "c3e88d";
            teal = "89ddff";
            cyan = "89ddff";
            blue = "82aaff";
            sapphire = "82aaff";
            purple = "c792ea";
            mauve = "c792ea";
            default = "82aaff";
          };
          ansi = [
            "212121"
            "ff5370"
            "c3e88d"
            "ffcb6b"
            "82aaff"
            "c792ea"
            "89ddff"
            "eeeeee"
            "545b65"
            "ff5370"
            "c3e88d"
            "ffcb6b"
            "82aaff"
            "c792ea"
            "89ddff"
            "efffff"
          ];
        };
        dark = {
          title = "Dark";
          polarity = "dark";
          ghostty = "Material Dark";
          base = "222221";
          mantle = "212120";
          crust = "1f1f1e";
          surface0 = "373736";
          surface1 = "4d4d4c";
          surface2 = "626262";
          overlay0 = "787878";
          overlay1 = "8e8e8d";
          overlay2 = "a4a4a3";
          subtext0 = "b9b9b9";
          subtext1 = "cfcfcf";
          text = "e4e4e4";
          accents = {
            rosewater = "9bb0d2";
            lavender = "6287c5";
            red = "b7141e";
            maroon = "e83a3f";
            peach = "f5971d";
            orange = "f5971d";
            yellow = "f5971d";
            green = "457b23";
            teal = "0e707c";
            cyan = "26bad1";
            blue = "134eb2";
            sapphire = "53a4f3";
            purple = "550087";
            mauve = "a94dbb";
            default = "134eb2";
          };
          ansi = [
            "212121"
            "b7141e"
            "457b23"
            "f5971d"
            "134eb2"
            "550087"
            "0e707c"
            "eeeeee"
            "424242"
            "e83a3f"
            "7aba39"
            "fee92e"
            "53a4f3"
            "a94dbb"
            "26bad1"
            "d8d8d8"
          ];
        };
        ocean = {
          title = "Ocean";
          polarity = "dark";
          ghostty = "Material Ocean";
          base = "0f111a";
          mantle = "0e1019";
          crust = "0e1018";
          surface0 = "282b33";
          surface1 = "41464d";
          surface2 = "596066";
          overlay0 = "737b80";
          overlay1 = "8b9599";
          overlay2 = "a5b0b3";
          subtext0 = "bdcacc";
          subtext1 = "d6e5e6";
          text = "efffff";
          accents = {
            rosewater = "c9e1ff";
            lavender = "abcaff";
            red = "ff5370";
            maroon = "ff5370";
            peach = "f78c6c";
            orange = "f78c6c";
            yellow = "ffcb6b";
            green = "c3e88d";
            teal = "89ddff";
            cyan = "89ddff";
            blue = "82aaff";
            sapphire = "82aaff";
            purple = "c792ea";
            mauve = "c792ea";
            default = "82aaff";
          };
          ansi = [
            "0f111a"
            "ff5370"
            "c3e88d"
            "ffcb6b"
            "82aaff"
            "c792ea"
            "89ddff"
            "eeeeee"
            "545b65"
            "ff5370"
            "c3e88d"
            "ffcb6b"
            "82aaff"
            "c792ea"
            "89ddff"
            "efffff"
          ];
        };
        light = {
          title = "Light";
          polarity = "light";
          ghostty = "Material";
          base = "eaeaea";
          mantle = "e0e0e0";
          crust = "d5d5d5";
          surface0 = "c1c1c1";
          surface1 = "adadad";
          surface2 = "9a9a99";
          overlay0 = "868685";
          overlay1 = "717171";
          overlay2 = "5d5d5d";
          subtext0 = "4a4a49";
          subtext1 = "363635";
          text = "222221";
          accents = {
            rosewater = "1e2f4c";
            lavender = "1a3a71";
            red = "b7141e";
            maroon = "e83a3f";
            peach = "f5971d";
            orange = "f5971d";
            yellow = "f5971d";
            green = "457b23";
            teal = "0e707c";
            cyan = "26bad1";
            blue = "134eb2";
            sapphire = "53a4f3";
            purple = "550087";
            mauve = "a94dbb";
            default = "134eb2";
          };
          ansi = [
            "212121"
            "b7141e"
            "457b23"
            "f5971d"
            "134eb2"
            "550087"
            "0e707c"
            "eeeeee"
            "424242"
            "e83a3f"
            "7aba39"
            "fee92e"
            "53a4f3"
            "a94dbb"
            "26bad1"
            "d8d8d8"
          ];
        };
      };
    };
    Yoru = {
      title = "Yoru";
      flavors = {
        dark = {
          title = "Dark";
          polarity = "dark";
          base = "0c0e0f";
          mantle = "0c0d0e";
          crust = "0b0d0e";
          surface0 = "252728";
          surface1 = "3e4041";
          surface2 = "57595a";
          overlay0 = "707273";
          overlay1 = "898b8c";
          overlay2 = "a2a4a5";
          subtext0 = "bbbdbe";
          subtext1 = "d4d6d7";
          text = "edeff0";
          accents = {
            rosewater = "becee2";
            lavender = "9ab5d8";
            red = "df5b61";
            maroon = "e8646a";
            peach = "e79881";
            orange = "e79881";
            yellow = "de8f78";
            green = "78b892";
            teal = "67afc1";
            cyan = "70b8ca";
            blue = "6791c9";
            sapphire = "709ad2";
            purple = "bc83e3";
            mauve = "c58cec";
            default = "6791c9";
          };
          ansi = [
            "232526"
            "df5b61"
            "78b892"
            "de8f78"
            "6791c9"
            "bc83e3"
            "67afc1"
            "e4e6e7"
            "2c2e2f"
            "e8646a"
            "81c19b"
            "e79881"
            "709ad2"
            "c58cec"
            "70b8ca"
            "f2f4f5"
          ];
        };
      };
    };
    Mountain = {
      title = "Mountain";
      flavors = {
        dark = {
          title = "Dark";
          polarity = "dark";
          base = "0f0f0f";
          mantle = "0e0e0e";
          crust = "0e0e0e";
          surface0 = "282828";
          surface1 = "414141";
          surface2 = "5a5a5a";
          overlay0 = "737373";
          overlay1 = "8c8c8c";
          overlay2 = "a5a5a5";
          subtext0 = "bebebe";
          subtext1 = "d7d7d7";
          text = "f0f0f0";
          accents = {
            rosewater = "d5d3e1";
            lavender = "c0bdd5";
            red = "ac8a8c";
            maroon = "c49ea0";
            peach = "c49e9e";
            orange = "c49e9e";
            yellow = "aca98a";
            green = "8aac8b";
            teal = "8aacab";
            cyan = "9ec3c4";
            blue = "8f8aac";
            sapphire = "a39ec4";
            purple = "ac8aac";
            mauve = "c49ec4";
            default = "a39ec4";
          };
          ansi = [
            "4c4c4c"
            "ac8a8c"
            "8aac8b"
            "aca98a"
            "8f8aac"
            "ac8aac"
            "8aacab"
            "f0f0f0"
            "262626"
            "c49ea0"
            "9ec49f"
            "c4c19e"
            "a39ec4"
            "c49ec4"
            "9ec3c4"
            "e7e7e7"
          ];
        };
      };
    };
  };

  isHex = s: (builtins.match "[#]?[0-9a-fA-F]{6}" s) != null;

  # Pure-builtin string helpers (kept dependency-free on purpose: { lib } is
  # still accepted for call-site compatibility, but the logic below must not
  # rely on any lib.* attribute).
  stripHash = s: if builtins.substring 0 1 s == "#" then builtins.substring 1 (-1) s else s;

  # Split on single spaces, drop empties and newlines. Handles the persisted
  # "theme flavor accent\n" selection file. (builtins.split yields the
  # separators themselves as inert `[ ]` entries — drop anything non-string.)
  words =
    s:
    builtins.filter (x: builtins.typeOf x == "string" && x != "") (
      builtins.split " " (builtins.replaceStrings [ "\n" ] [ "" ] s)
    );

  # The home-manager catppuccin module (and therefore the accent name
  # scripts/theme writes into src/selection for Stylix) uses catppuccin/nvim's
  # accent list, which names one color differently from the database above.
  # Resolve those aliases to the same hex instead of falling through to the
  # "unknown accent" branch, which silently picked the first accent (blue).
  # Upstream accent names people actually type, mapped onto the closest key this
  # DB defines. `theme list` prints the DB names; these accept the aliases too so
  # e.g. `theme Nord light frost` does not error out.
  accentAliases = {
    sky = "cyan";
    frost = "cyan"; # Nord
    polar = "blue"; # Nord
    aurora = "green"; # Nord
    pink = "purple"; # Material
    iris = "purple"; # Rosé Pine
    love = "red"; # Rosé Pine
    foam = "cyan"; # Rosé Pine
    gold = "yellow"; # Rosé Pine
    pine = "green"; # Rosé Pine
    waveBlue = "sapphire"; # Kanagawa
    lotusPink = "purple"; # Kanagawa
    dragonBlue = "blue"; # Kanagawa
  };

  # Resolve a raw variant slot into normalized roles given a chosen accent name.
  # Returns raw hex (no '#'). Supports custom hex accents ("#aabbcc" / "aabbcc")
  # in addition to named accents from the palette.
  resolve =
    v: accent:
    let
      stripped = stripHash accent;
      lookup = if v.accents ? ${accent} then accent else accentAliases.${accent} or accent;
      resolvedAccent =
        if v.accents ? ${lookup} then
          v.accents.${lookup}
        else if accent == "default" then
          v.text
        else if isHex accent then
          stripped
        else
          v.accents.default or (builtins.head (builtins.attrValues v.accents));
    in
    {
      polarity = v.polarity;
      title = v.title;
      accentName = if (v.accents ? ${lookup}) || accent == "default" then accent else stripped;
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

      # The named roles are emitted alongside the base16 slots so consumers can
      # layer backgrounds by name. base16 collapses the 4-step neutral ramp
      # (crust/mantle/base/surface0) onto base00..base02, which leaves no way to
      # give the editor, the bufferline bar and the file explorer distinct
      # backgrounds. base16-nvim only reads base0[0-9A-F], so these extra keys
      # are inert there and are consumed by nvim's lua/theme.lua.
      crust = h r.crust;
      mantle = h r.mantle;
      base = h r.base;
      surface0 = h r.surface0;
      surface1 = h r.surface1;
      surface2 = h r.surface2;
      overlay0 = h r.overlay0;
      overlay1 = h r.overlay1;
      overlay2 = h r.overlay2;
      subtext0 = h r.subtext0;
      subtext1 = h r.subtext1;
      text = h r.text;
      accent = h r.accent;
      # Named accents with no base16 slot, exported for nvim's mode colours:
      # base0E is already the mauve slot, but there is no blue one at all.
      blue = h (a "blue" (ansi 4));
      mauve = h (a "mauve" (a "purple" (ansi 5)));
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
      part = n: if builtins.length parts > n then builtins.elemAt parts n else "";
      themeName =
        let
          t = part 0;
        in
        if t != "" && builtins.hasAttr t themes then t else defaults.theme;
      flavorName =
        let
          f = part 1;
        in
        if f != "" && builtins.hasAttr f themes.${themeName}.flavors then f else defaults.flavor;
      accentsOf = themes.${themeName}.flavors.${flavorName}.accents;
      accentName =
        let
          a = part 2;
        in
        if
          a != "" && (a == "default" || builtins.hasAttr a accentsOf || accentAliases ? ${a} || isHex a)
        then
          a
        else
          defaults.accent;
      flavor = themes.${themeName}.flavors.${flavorName};
      # Override selective base16-scheme `name` is derived from the DB keys:
      # no builtin promotes to lowercase, but the theme/flavor keys already are.
      name = if flavorName == "default" then themeName else "${themeName}-${flavorName}";
      r = (resolve flavor accentName) // {
        inherit name;
      };
    in
    {
      inherit
        themeName
        flavorName
        accentName
        name
        flavor
        r
        ;
    };
in
{
  inherit
    themes
    resolve
    toBase16
    readSelection
    ;
}
