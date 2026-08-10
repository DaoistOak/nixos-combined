{
  config,
  lib,
  ...
}:

{
  wayland.windowManager.hyprland.settings.config = {
    # plugin.overview = {
    #   # Catppuccin Macchiato palette (matches the rest of the config)
    #   panelColor = "0x99131a24";
    #   panelBorderColor = "0xf0ffffff";
    #   workspaceActiveBackground = "0x3a0e131c";
    #   workspaceInactiveBackground = "0x66131824";
    #   workspaceActiveBorder = "0xf0ffffff";
    #   workspaceInactiveBorder = "0x66ffffff";
    #   centerAligned = 1;
    #   hideTopLayers = 1;
    #   hideBackgroundLayers = 1;
    #   hideOverlayLayers = 1;
    # };
    showNewWorkspace = 1;
    showEmptyWorkspace = 0;
    showSpecialWorkspace = 1;
    exitOnClick = 1;
    exitOnSwitch = 1;
    switchOnDrop = 1;
    autoDrag = 1;
  };
}