# Animation preset selection.
# Available presets: fast, fancy, medium, smooth
#   fast  - snappy, minimal motion (speed 1-3)
#   fancy - md3 curves, medium speeds (default, previously the only preset)
#   medium - balanced, unobtrusive (speed 3-6)
#   smooth - fluid with subtle overshoot (speed 3-10)
# Switch by editing the imported file below.
{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./animations/fancy.nix
  ];
}
