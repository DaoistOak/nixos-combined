{
  ...
}:
{
  # Two layers theme qutebrowser:
  #
  #  1. Build time (Stylix's qutebrowser target, auto-enabled): fonts plus a
  #     complete ~90-option base16 mapping on `programs.qutebrowser.settings`,
  #     generated from src/selection. It is a full fallback: qutebrowser looks
  #     themed even if scripts/theme never ran.
  #  2. Runtime: extraConfig below exec()s ~/.config/qutebrowser/noctalia/
  #     colors.py (rewritten by scripts/theme, no rebuild) and maps its
  #     Material-3 roles onto every color option. HM appends extraConfig after
  #     the settings, so the runtime palette wins; autoconfig.yml (GUI tweaks)
  #     loads first and loses to both.
  programs.qutebrowser = {
    enable = true;
    # qutebrowser itself comes from system-packages (pkgs/default.nix); don't
    # pull a second copy of it into the user profile.
    package = null;
    loadAutoconfig = true;

    extraConfig = ''
      # Runtime Material-3 palette from scripts/theme.
      import os

      palette_path = os.path.expanduser("~/.config/qutebrowser/noctalia/colors.py")
      if os.path.exists(palette_path):
          with open(palette_path) as palette_file:
              exec(palette_file.read())

          # completion
          c.colors.completion.category.bg = primary_container
          c.colors.completion.category.fg = on_primary_container
          c.colors.completion.category.border.bottom = primary_container
          c.colors.completion.category.border.top = primary_container
          c.colors.completion.even.bg = surface
          c.colors.completion.odd.bg = surface_container_low
          c.colors.completion.fg = on_surface
          c.colors.completion.match.fg = primary
          c.colors.completion.item.selected.bg = primary
          c.colors.completion.item.selected.fg = on_primary
          c.colors.completion.item.selected.border.bottom = primary
          c.colors.completion.item.selected.border.top = primary
          c.colors.completion.item.selected.match.fg = on_primary_container
          c.colors.completion.scrollbar.bg = surface_container_high
          c.colors.completion.scrollbar.fg = on_surface_variant

          # context menu
          c.colors.contextmenu.menu.bg = surface_container
          c.colors.contextmenu.menu.fg = on_surface
          c.colors.contextmenu.selected.bg = primary
          c.colors.contextmenu.selected.fg = on_primary
          c.colors.contextmenu.disabled.bg = surface_container_low
          c.colors.contextmenu.disabled.fg = outline

          # downloads
          c.colors.downloads.bar.bg = surface_container
          c.colors.downloads.error.bg = error
          c.colors.downloads.error.fg = on_error
          c.colors.downloads.start.bg = primary
          c.colors.downloads.start.fg = on_primary
          c.colors.downloads.stop.bg = secondary
          c.colors.downloads.stop.fg = on_secondary

          # hints
          c.colors.hints.bg = surface_container_highest
          c.colors.hints.fg = on_surface
          c.colors.hints.match.fg = primary

          # keyhint
          c.colors.keyhint.bg = surface_container
          c.colors.keyhint.fg = on_surface
          c.colors.keyhint.suffix.fg = on_surface_variant

          # messages
          c.colors.messages.error.bg = error
          c.colors.messages.error.fg = on_error
          c.colors.messages.error.border = error
          c.colors.messages.warning.bg = tertiary
          c.colors.messages.warning.fg = on_tertiary
          c.colors.messages.warning.border = tertiary
          c.colors.messages.info.bg = secondary
          c.colors.messages.info.fg = on_secondary
          c.colors.messages.info.border = secondary

          # prompts
          c.colors.prompts.bg = surface_container_high
          c.colors.prompts.fg = on_surface
          c.colors.prompts.border = f"1px solid {outline_variant}"
          c.colors.prompts.selected.bg = primary
          c.colors.prompts.selected.fg = on_primary

          # statusbar
          c.colors.statusbar.normal.bg = surface_container
          c.colors.statusbar.normal.fg = on_surface
          c.colors.statusbar.insert.bg = primary
          c.colors.statusbar.insert.fg = on_primary
          c.colors.statusbar.command.bg = surface_container_low
          c.colors.statusbar.command.fg = on_surface
          c.colors.statusbar.command.private.bg = surface_container_high
          c.colors.statusbar.command.private.fg = on_surface
          c.colors.statusbar.passthrough.bg = secondary
          c.colors.statusbar.passthrough.fg = on_secondary
          c.colors.statusbar.private.bg = surface_variant
          c.colors.statusbar.private.fg = on_surface_variant
          c.colors.statusbar.caret.bg = tertiary
          c.colors.statusbar.caret.fg = on_tertiary
          c.colors.statusbar.caret.selection.bg = primary_container
          c.colors.statusbar.caret.selection.fg = on_primary_container
          c.colors.statusbar.progress.bg = primary
          c.colors.statusbar.url.fg = on_surface_variant
          c.colors.statusbar.url.hover.fg = primary
          c.colors.statusbar.url.error.fg = error
          c.colors.statusbar.url.warn.fg = tertiary
          c.colors.statusbar.url.success.http.fg = secondary
          c.colors.statusbar.url.success.https.fg = primary

          # tabs
          c.colors.tabs.bar.bg = surface
          c.colors.tabs.odd.bg = surface
          c.colors.tabs.odd.fg = on_surface
          c.colors.tabs.even.bg = surface_container_low
          c.colors.tabs.even.fg = on_surface
          c.colors.tabs.selected.odd.bg = primary_container
          c.colors.tabs.selected.odd.fg = on_primary_container
          c.colors.tabs.selected.even.bg = primary_container
          c.colors.tabs.selected.even.fg = on_primary_container
          c.colors.tabs.pinned.odd.bg = secondary_container
          c.colors.tabs.pinned.odd.fg = on_secondary_container
          c.colors.tabs.pinned.even.bg = surface_container_high
          c.colors.tabs.pinned.even.fg = on_surface
          c.colors.tabs.pinned.selected.odd.bg = primary_container
          c.colors.tabs.pinned.selected.odd.fg = on_primary_container
          c.colors.tabs.pinned.selected.even.bg = primary_container
          c.colors.tabs.pinned.selected.even.fg = on_primary_container
          c.colors.tabs.indicator.start = secondary
          c.colors.tabs.indicator.stop = primary
          c.colors.tabs.indicator.error = error

          # tooltip
          c.colors.tooltip.bg = inverse_surface
          c.colors.tooltip.fg = inverse_on_surface

          # webpage: Stylix only sets preferred_color_scheme (and only for dark
          # polarity, at build time), so redo it from the runtime polarity --
          # `theme set <light> --runtime` never rebuilds. pages with no
          # background of their own otherwise flash white under a dark palette.
          c.colors.webpage.bg = surface
          c.colors.webpage.preferred_color_scheme = "dark" if polarity == "dark" else "light"
    '';
  };

  # Disable the catppuccin-generated theme: its setup() is injected with
  # mkAfter, so it would run after (and stomp) the runtime palette above.
  # Stylix already provides the build-time layer, for every theme rather than
  # catppuccin alone.
  catppuccin.qutebrowser.enable = false;
}
