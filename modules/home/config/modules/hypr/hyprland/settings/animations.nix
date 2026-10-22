# Animation preset selection.
# Available presets: fast, fancy, medium, smooth
#   fast  - snappy, minimal motion (speed 1-3)
#   fancy - md3 curves, medium speeds (default, previously the only preset)
#   medium - balanced, unobtrusive (speed 3-6)
#   smooth - fluid with subtle overshoot (speed 3-10)
# Switch by editing the imported file below.
#
# The presets live in _presets/ because import-tree auto-loads every .nix in
# this tree: the leading `_` is what keeps all four out of that sweep so only
# the one imported here is active.
{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./animations/_presets/smooth.nix
  ];
}
