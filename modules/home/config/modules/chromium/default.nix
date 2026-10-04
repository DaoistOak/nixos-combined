# Chromium user-level files.
#
# The extensions themselves are system packages (pkgs/chromium-extensions), but
# user.js lives in the profile so the browser picks it up on every start.
# Remember: user.js overrides the profile's stored Preferences, so edit it here
# rather than in chrome://settings.
{
  xdg.configFile."chromium/user.js" = {
    source = ./src/user.js;
  };
}