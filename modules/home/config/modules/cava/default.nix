{
  config,
  lib,
  ...
}:
{
  xdg.configFile."cava/config" = {
    source = ./src/config;
    # unmanaged previously; now declared so `~/.config/cava/config` is
    # reproducible. `method = noncurses` (instead of ncurses) because WezTerm
    # reports it cannot change color definitions, which ncurses mode requires
    # for hex gradient colors.
  };
}
