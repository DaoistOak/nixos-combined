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
        image = [
          {
            run = "gwenview %s";
            desc = "Open with Gwenview";
          }
        ];
        pdf = [
          {
            run = "okular %s";
            desc = "Open with Okular";
          }
        ];
        word = [
          {
            run = "wps %s";
            desc = "Open with WPS Office";
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
          {
            mime = "image/*";
            use = "image";
          }
          {
            mime = "application/pdf";
            use = "pdf";
          }
          # Word docs (.doc / .docx)
          {
            mime = "application/msword";
            use = "word";
          }
          {
            mime = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            use = "word";
          }
          # Fall back to name matching in case mime detection misses docx/doc.
          {
            name = "*.docx";
            use = "word";
          }
          {
            name = "*.doc";
            use = "word";
          }
        ];
      };
    };
  };

  # Writes theme.toml from the global catppuccin flavor (macchiato) + accent (mauve).
  catppuccin.yazi.enable = true;
}
