{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Same family as the terminals (alacritty/kitty/ghostty). It has to be the
  # Nerd Font variant, not stylix' plain "JetBrains Mono": LazyVim draws its
  # icons (mini.icons) and this repo's showbreak with private-use codepoints.
  fontFamily = "JetBrainsMono Nerd Font";
in
{
  programs.neovide = {
    enable = true;
    package = pkgs.neovide;

    # Written to ~/.config/neovide/config.toml. programs.neovide.settings is a
    # freeform TOML submodule: home-manager does not type-check these keys, and
    # neovide ignores the ones it does not know, so an option that is not listed
    # in src/settings/config.rs is a silent no-op (an old "no-proxy" lived here).
    settings = {
      # Decorations. "full" keeps the compositor-drawn title bar, which is what
      # the hyprland keybinds' class regex matches on.
      frame = "full";

      # GUI font. 13pt instead of the terminals' 10pt: neovide has no line-height
      # compression, so a terminal-sized font reads cramped in a window.
      font = {
        normal = {
          family = fontFamily;
          style = "Normal";
        };
        bold = {
          family = fontFamily;
          style = "Bold";
        };
        italic = {
          family = fontFamily;
          style = "Italic";
        };
        bold_italic = {
          family = fontFamily;
          style = "Bold Italic";
        };
        size = 13.0;
        hinting = "full";
        edging = "antialias";
      };

      # Box drawing: `mode` defaults to "native", which draws the box/powerline
      # glyphs with the rect renderer instead of the font's, so neovim's own
      # borders do not leave hairline gaps between cells. Only the line
      # thickness is overridden, because the 2/4px default is too heavy at 13pt.
      # ("selected-native" would need a list of Nerd Font codepoints here, which
      # does not survive home-manager's TOML generator intact - it writes them
      # out as literal "u{E0B0}" text.)
      box-drawing.sizes.default = [
        1
        2
      ];

      # Multigrid on (blurred float backgrounds, smooth scroll, window
      # animations). Leave it on unless neovim-side rendering misbehaves.
      no-multigrid = false;

      # Only render frames when something changed.
      idle = true;

      # Sync to the display refresh instead of rendering unthrottled.
      vsync = true;

      # Terminals-style sRGB; the Linux default, spelled out because a wrong
      # value here shows up as wrong colors on some compositors.
      srgb = false;

      # Neovide opens `neovide a b c` as one tab per file. LazyVim draws its own
      # tabline, so the extra tabs are just clutter.
      tabs = false;

      # Stable window identity for hyprland rules (keybinds.nix matches on the
      # `neovide` class); neovide otherwise derives a per-instance class.
      wayland-app-id = "neovide";
      x11-wm-class = "neovide";
      x11-wm-class-instance = "neovide";
    };
  };

  # Stylix' neovide target forces stylix.fonts.monospace ("JetBrains Mono", the
  # plain font, not the Nerd Font the terminals use) and fonts.sizes.terminal
  # (10, a terminal size) into programs.neovide.settings.font, so it owns the
  # font by default. It also types font.normal as a plain string list, which
  # rejects the family/style tables below. Drop it and keep the font here, next
  # to the rest of the neovide config: same reason stylix.targets.neovim is off
  # in the nvim module. The other half of that target only injected
  # vim.g.neovide_normal_opacity = 1 (stylix.opacity is unset), so nothing else
  # is lost.
  stylix.targets.neovide.enable = false;
}
