{
  config,
  lib,
  ...
}:
let
  # Active theme roles (themes/colors resolves the persisted selection).
  a = config.colors.active;
  h = v: "#${v}";
in
{
  xdg.configFile."cava/config" = {
    source = ./src/config;
    # unmanaged previously; now declared so `~/.config/cava/config` is
    # reproducible. `method = noncurses` (instead of ncurses) because WezTerm
    # reports it cannot change color definitions, which ncurses mode requires
    # for hex gradient colors.
  };

  # Build-time fallback for the color theme (see [color] in src/config): the
  # same 8-step ramp scripts/theme's gen_cava_theme writes at runtime --
  # neutral surfaces at the bottom rising to the accent on top -- so cava is
  # themed from the first switch, before any `theme set` has run. force = true
  # restores this store link on the next switch; gen_cava_theme rm's it and
  # writes a real file so the runtime copy can differ (e.g. --runtime switches,
  # which don't rebuild).
  xdg.configFile."cava/themes/theme-switcher" = {
    force = true;
    text = ''
      # Generated at build time from src/selection — scripts/theme rewrites
      # this file on every `theme set`. cava derives gradient_count from the
      # consecutive gradient_color_N keys and reads background from the
      # terminal ("default").
      [color]
      foreground = '${h a.accent}'
      gradient = 1
      gradient_color_1 = '${h a.surface1}'
      gradient_color_2 = '${h a.surface2}'
      gradient_color_3 = '${h a.overlay0}'
      gradient_color_4 = '${h a.overlay1}'
      gradient_color_5 = '${h a.overlay2}'
      gradient_color_6 = '${h a.subtext0}'
      gradient_color_7 = '${h a.subtext1}'
      gradient_color_8 = '${h a.accent}'
    '';
  };
}
