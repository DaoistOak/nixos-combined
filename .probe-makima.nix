let
  src = /home/zeph/.config/nixos;
  lock = builtins.readFile (src + "/flake.lock");
  # parse the nixpkgs locked rev from the flake.lock JSON
  id = builtins.fromJSON lock;
  np = id.nodes."nixpkgs".locked.rev;
in
with (import (src + "/../nixpkgs" ? "/nixpkgs") { inherit src; });
# use the flake's nixpkgs directly
import (builtins.getEnv "NIX_PATH_OVERRIDE") {}
