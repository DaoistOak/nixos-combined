# Installs `updt` and `theme` onto PATH as thin wrappers that export the
# config.var values before exec'ing the real scripts in the repo. The scripts
# themselves keep sensible fallbacks so `./scripts/updt` still works standalone
# (e.g. before the first rebuild); the wrapper is what makes the var module the
# single source of truth once installed.
{ config, pkgs, ... }:
let
  exportVars = ''
    export CONFIG_VAR_HOSTNAME="${config.var.hostname}"
    export CONFIG_VAR_USERNAME="${config.var.username}"
    export CONFIG_VAR_CONFIG_DIRECTORY="${config.var.configDirectory}"
  '';
in
{
  home.packages = [
    (pkgs.writeShellScriptBin "updt" ''
      ${exportVars}
      exec "${config.var.configDirectory}/scripts/updt" "$@"
    '')
    (pkgs.writeShellScriptBin "theme" ''
      ${exportVars}
      exec "${config.var.configDirectory}/scripts/theme" "$@"
    '')
  ];
}
