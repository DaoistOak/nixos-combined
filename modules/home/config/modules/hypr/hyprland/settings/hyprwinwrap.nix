{
  config,
  lib,
  ...
}:

{
  wayland.windowManager.hyprland.extraConfig = ''
    if hl.plugin.hyprwinwrap ~= nil then
      -- Declare which window(s) act as live wallpapers. class/title are EXACT
      -- matches (use `hyprctl clients` to find them). Launch e.g.:
      --   kitty --class=window-bg -o background_opacity=0.0 <script>
      hl.plugin.hyprwinwrap.window({
        class = "window-bg",
        title = "window-bg",
        layer = 0,
        pos_x = 0,
        pos_y = 0,
        size_x = 100,
        size_y = 97,
      })

      -- Toggle focus/editing on the background window (SUPER + B)
      hl.bind("SUPER + B", function()
        hl.plugin.hyprwinwrap.focus("window-bg")
      end, { description = "Toggle hyprwinwrap background focus" })
    end
  '';
}
