{ pkgs, lib, ... }:
let
  # Registered file-by-file instead of symlinking the whole ~/.config/rofi
  # directory into the Nix store. scripts/theme writes the generated
  # colors/theme-switcher.rasi there at runtime, and a store-backed directory
  # is read-only, so `cat >` there aborted `theme set` under `set -e`.
  # Per-file entries keep ~/.config/rofi and ~/.config/rofi/colors as real
  # directories while the individual .rasi files stay store symlinks.
  walk =
    dir: prefix:
    lib.foldl' (
      acc: name:
      let
        entry = (builtins.readDir dir).${name};
        path = "${dir}/${name}";
        rel = "${prefix}${name}";
      in
      if entry == "directory" then
        acc // walk path "${rel}/"
      else
        acc
        // {
          ${rel} = {
            source = path;
            force = true;
          };
        }
    ) { } (lib.attrNames (builtins.readDir dir));

  rofiFiles = lib.mapAttrs' (name: value: lib.nameValuePair "rofi/${name}" value) (
    walk ./src/rofi ""
  );
in
{
  home.packages = [ pkgs.rofi ];

  xdg.configFile = rofiFiles;
}
