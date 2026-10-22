{ config, ... }:
let
  # KeePassXC only offers classic/dark/light (no custom palettes), so polarity
  # from the active selection is the whole story.
  applicationTheme = if config.colors.active.polarity == "light" then "light" else "dark";
in
{
  xdg.configFile."keepassxc/keepassxc.ini" = {
    force = true;
    text = ''
      [General]
      AutoReloadOnChange=true
      AutoSaveAfterEveryChange=true
      AutoSaveNonDataChanges=true
      AutoSaveOnExit=true
      ConfigVersion=2
      NumberOfRememberedLastDatabases=17

      [Browser]
      CustomProxyLocation=
      Enabled=true

      [GUI]
      ApplicationTheme=${applicationTheme}
      ColorPasswords=true
      CompactMode=false
      HidePasswords=true
      Language=system
      MinimizeOnClose=true
      MinimizeOnStartup=true
      MinimizeToTray=true
      MonospaceNotes=true
      MovableToolbar=true
      ShowTrayIcon=true
      TrayIconAppearance=monochrome-light

      [KeeShare]
      QuietSuccess=true

      [PasswordGenerator]
      AdditionalChars=
      AdvancedMode=true
      Braces=true
      ExcludedChars=
      Length=16
      Logograms=false
      Math=false
      Punctuation=true
    '';
  };
}
