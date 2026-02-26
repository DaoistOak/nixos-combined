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
  modifications = final: prev: {
    # Disable Python 3.11 docs to avoid sphinx build issues
    python311 = prev.python311.override { doc = false; };

    # Allow sphinx 9.1.0 with Python 3.11 (if needed)
    python311Packages.sphinx = prev.python311Packages.sphinx.overridePythonAttrs (oldAttrs: {
      disabled = false;
    });
  };

  # NUR (Nix User Repository) overlay
  nur = inputs.nur.overlays.default;

}
