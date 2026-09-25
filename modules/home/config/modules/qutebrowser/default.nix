{
  ...
}:
{
  # Load the Noctalia Material Design 3 theme (written to
  # ~/.config/qutebrowser/noctalia/colors.py outside of this repo) as the base
  # qutebrowser theme. Guarded so a missing colors file falls back to defaults.
  home.file.".config/qutebrowser/config.py" = {
    force = true;
    text = ''
      import os

      config.load_autoconfig()
      colors_path = os.path.expanduser("~/.config/qutebrowser/noctalia/colors.py")
      if os.path.exists(colors_path):
          exec(open(colors_path).read())
    '';
  };
}
