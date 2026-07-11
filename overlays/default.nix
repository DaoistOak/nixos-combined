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
    # vulkan-validation-layers defaults UPDATE_DEPS=ON which runs
    # update_deps.py (needs git + network). Nix provides deps, so disable it.
    vulkan-validation-layers = prev.vulkan-validation-layers.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ final.git ];
      cmakeFlags = (old.cmakeFlags or []) ++ [ "-DUPDATE_DEPS=OFF" ];
    });

    # Generalize Python package overrides to all versions
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
