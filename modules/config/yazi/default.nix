{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.yazi = {
    enable = true;
    # yazi is already a system package (pkgs/default.nix); keep it out of the
    # home profile so it is not installed twice.
    package = null;

    settings = {
      # Text files open in nvim by default via the `edit` opener.
      opener = {
        edit = [
          {
            run = "nvim %s";
            block = true;
            desc = "Edit with nvim";
          }
        ];
      };
      open = {
        # Prepend: takes precedence over yazi's defaults (which route text/*
        # to $EDITOR anyway, but this pins it to nvim via the opener above).
        prepend_rules = [
          {
            mime = "text/*";
            use = "edit";
          }
        ];
      };
    };
  };

  # Writes theme.toml from the global catppuccin flavor (macchiato) + accent (mauve).
  catppuccin.yazi.enable = true;
}
