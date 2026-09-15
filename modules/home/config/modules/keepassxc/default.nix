{ ... }:
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
      ApplicationTheme=classic
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
