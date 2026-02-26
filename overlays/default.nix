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
    # python311 = prev.python311.override { doc = false; };

    python311Packages = prev.python311Packages.override {
      overrides = self: super: {
        sphinx = super.sphinx.overridePythonAttrs (oldAttrs: {
          disabled = false;
        });
        picosvg = super.picosvg.overridePythonAttrs (oldAttrs: {
          doCheck = false;
        });
      };
    };

    # Same for python313 if present
    # python313 = prev.python313.override { doc = false; };
    python313Packages = prev.python313Packages.override {
      overrides = self: super: {
        sphinx = super.sphinx.overridePythonAttrs (oldAttrs: {
          disabled = false;
        });
        picosvg = super.picosvg.overridePythonAttrs (oldAttrs: {
          doCheck = false;
        });
      };
    };
  };

  # NUR (Nix User Repository) overlay
  nur = inputs.nur.overlays.default;

}
