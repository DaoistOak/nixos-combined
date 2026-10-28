{
  config,
  lib,
  ...
}:
let
  # Resolved roles from the active selection (themes/colors).
  r = config.colors.active;
  h = v: "#${v}";
  # Catppuccin-style accent hues with ANSI fallbacks — same chains as
  # resolve_json's jq in scripts/theme, so the build-time fallback and the
  # runtime file it ships stay byte-identical.
  acc = name: fallback: r.accents.${name} or fallback;
  green = h (acc "green" (builtins.elemAt r.ansi 2));
  peach = h (acc "peach" (acc "orange" (builtins.elemAt r.ansi 3)));
  red = h (acc "red" r.base);
  teal = h (acc "teal" (builtins.elemAt r.ansi 6));
  maroon = h (acc "maroon" (builtins.elemAt r.ansi 9));
in
{
  programs.atuin = {
    enable = true;
    enableZshIntegration = false;
    settings = {
      enter_accept = true;
      # Own 8-color theme instead of catppuccin's fixed
      # "catppuccin-<flavor>-<accent>" (which never followed `theme set`).
      # rewrites it in place on every switch; atuin reads config+theme on each
      # TUI start, so no reload is needed.
      theme.name = "theme-switcher";
    };
  };

  # file; both lose to the layer above (see qutebrowser for the same pattern).
  catppuccin.atuin.enable = false;

  xdg.configFile."atuin/themes/theme-switcher.toml" = {
    force = true;
    text = ''
      # this file on every `theme set` (rm -f first, it starts as this store
      # link).
      [theme]
      name = "theme-switcher"

      [colors]
      AlertInfo = '${green}'
      AlertWarn = '${peach}'
      AlertError = '${red}'
      Annotation = '${teal}'
      Base = '${h r.text}'
      Guidance = '${h r.subtext0}'
      Important = '${maroon}'
      Title = '${h r.accent}'
    '';
  };
}
