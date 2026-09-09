{
  config,
  lib,
  pkgs,
  ...
}:
{
  xdg.configFile."superfile/config.toml" = {
    text = ''
      theme = "catppuccin-macchiato"
      editor = "nvim"
      auto_check_update = false
      default_open_file_preview = true
      show_image_preview = true

      # Map common text extensions to nvim so Enter opens them in the editor.
      # The file path is appended as the last argument. Must be the last table.
      [open_with]
      txt = "nvim"
      md = "nvim"
      toml = "nvim"
      conf = "nvim"
      cfg = "nvim"
      ini = "nvim"
      nix = "nvim"
      sh = "nvim"
      bash = "nvim"
      zsh = "nvim"
      fish = "nvim"
      py = "nvim"
      rs = "nvim"
      c = "nvim"
      h = "nvim"
      cpp = "nvim"
      hpp = "nvim"
      go = "nvim"
      js = "nvim"
      ts = "nvim"
      json = "nvim"
      yaml = "nvim"
      yml = "nvim"
      lua = "nvim"
      html = "nvim"
      css = "nvim"
      sql = "nvim"
      tex = "nvim"
      log = "nvim"
    '';
    recursive = false;
  };
}
