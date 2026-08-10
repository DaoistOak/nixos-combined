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
    # Lutris: wine/proton cannot find graphics libraries on NixOS because they
    # live in the nix store, outside Lutris's FHS library paths. Lutris
    # appends the inherited LD_LIBRARY_PATH to every game launch
    # (lutris/runtime.py), so pre-pending the Vulkan loader, GL drivers, X11
    # client libraries and Wine's host dependencies here fixes Vulkan/DXVK,
    # OpenGL, window creation and Wine boot (ntdll needs libunwind, fonts need
    # freetype/fontconfig) for all games globally.
    lutris = prev.symlinkJoin {
      name = "lutris-with-graphics-libs-${prev.lutris.version}";
      paths = [ prev.lutris ];
      nativeBuildInputs = [ final.makeWrapper ];
      postBuild = ''
        rm -f $out/bin/lutris
        makeWrapper ${prev.lutris}/bin/lutris $out/bin/lutris \
          --prefix LD_LIBRARY_PATH : ${
            final.lib.makeLibraryPath [
              final.vulkan-loader
              final.mesa
              final.libglvnd
              final.libx11
              final.libxext
              final.libxcursor
              final.libxi
              final.libxrandr
              final.libxinerama
              final.libxfixes
              final.libxcb
              final.libxrender
              final.libxdamage
              final.libxcomposite
              final.libxtst
              final.libxxf86vm
              final.libxshmfence
              final.libxkbcommon
              final.libpulseaudio
              final.alsa-lib
              final.libunwind
              final.freetype
              final.fontconfig
              final.libpng
              final.libjpeg
              final.libtiff
              final.giflib
              final.lcms2
              final.libusb1
              final.libv4l
              final.gsm
              final.libxml2
              final.libtheora
              final.libvorbis
              final.libsndfile
              final.openal
              final.cups
            ]
          }
      '';
    };

    # vulkan-validation-layers defaults UPDATE_DEPS=ON which runs
    # update_deps.py (needs git + network). Nix provides deps, so disable it.
    vulkan-validation-layers = prev.vulkan-validation-layers.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.git ];
      cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DUPDATE_DEPS=OFF" ];
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
