# Individual overlay definitions
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions =
    final: _prev:
    import ../pkgs {
      pkgs = final;
      inherit inputs;
    };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  # modifications = final: prev: {
  #   webcord = prev.webcord.overrideAttrs (oldAttrs: {
  #     makeCacheWritable = true;
  #     npmDepsHash = null;
  #     npmInstallFlags = [ "--legacy-peer-deps" ];
  #   });
  # };

  # NUR (Nix User Repository) overlay
  nur = inputs.nur.overlays.default;

  # Chaotic NYX overlay (if needed)
  chaotic = inputs.chaotic.overlays.default;
}
