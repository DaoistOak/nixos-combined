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
    # lazyvim-nix resolves LazyVim's plugin specs with
    # `pkgs.vimPlugins.${name} or null` (nix/lib/plugin-resolution.nix), but
    # nixpkgs replaced this removed plugin with a `throw` alias
    # (pkgs/.../plugins/aliases.nix, 2026-06-15). A `throw` *raises* instead of
    # yielding null, so the `or null` fallback never fires and the entire
    # home-manager config fails to evaluate. Nulling the attribute lets
    # lazyvim-nix skip the plugin exactly as it would have if the attribute had
    # never existed -- which is the pre-nixpkgs-change behaviour. Upstream
    # deleted the typescript.nvim repository, so there is nothing to lose.
    vimPlugins = prev.vimPlugins // {
      typescript-nvim = null;
    };
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

    # sesh pulls go-mockery in as a code-generation build tool and rebuilds it with
    # buildGo127Module, because sesh itself is a buildGo127Module package:
    #   nativeBuildInputs = [ (go-mockery.override { buildGoModule = buildGo127Module; }) ... ]
    #   preBuild = "mockery";
    # That override makes go-mockery compile with Go 1.27, and go-mockery's own
    # checkPhase (doCheck = 1) then regenerates mocks via `go run .`, using the
    # golang.org/x/tools version pinned in its go.mod. That x/tools predates Go
    # 1.27's export data format v5, so the suite dies with:
    #   cannot decode "context", export data version 5 is greater than maximum
    #   supported version 4
    # sesh: build with nixpkgs' default Go instead of Go 1.27.
    # sesh pulls go-mockery in as a code-generation build tool and rebuilds it
    # with its own Go version:
    #   nativeBuildInputs = [ (go-mockery.override { buildGoModule = buildGo127Module; }) ... ]
    #   preBuild = "mockery";
    # sesh ships no generated mocks, so mockery is genuinely required to build
    # it. With Go 1.27 that fails twice over: go-mockery's own checkPhase
    # regenerates mocks with `go run .` using the golang.org/x/tools pinned in
    # its go.mod, and so does sesh's preBuild -- but x/tools v0.49.0 (the same
    # version in both go.mods) only decodes up to export data format v4, which
    # is Go 1.26. Go 1.27 emits v5:
    #   cannot decode "context", export data version 5 is greater than maximum
    #   supported version 4
    # Neither sesh nor mockery actually needs Go 1.27 -- sesh's go.mod declares
    # `go 1.26.0` and mockery's declares `go 1.25.5`. nixpkgs' buildGo127Module
    # here just forces an unbuildable combination. Swapping it for buildGoModule
    # drops both to Go 1.26, which the pinned x/tools reads and writes fine, so
    # mocks generate and both test suites still run -- nothing gets skipped.
    sesh = prev.sesh.override { buildGo127Module = prev.buildGoModule; };

    # hypr-edgehover: forward edge-gap pointer motion to adjacent Hyprland windows.
    # Built against the flake Hyprland dev output (headers + hyprland.pc via
    # pkg-config). Its Requires deps come from hyprland's git-pinned ecosystem.
    # Main (77b5e14): "adapt to Hyprland v0.56" — builds against v0.56.1
    # headers (pre-#15779: desktop/view/Window.hpp still present).
    hyprEdgehover = import ../pkgs/hypr-edgehover.nix { inherit inputs; };

    # hyprwinwrap: display any window as a background/wallpaper in Hyprland.
    # Built against the flake Hyprland dev output (hyprland.pc via pkg-config).
    # Pinned to a72d3ee (v0.56.0 line in its hyprpm.toml; v0.56.1 is a patch on
    # the same ABI line).
    hyprWinwrap = import ../pkgs/hyprwinwrap.nix { inherit inputs; };

    # Unpacked Chromium extensions for --load-extension (the Chrome Web Store
    # install flow does not work in ungoogled-chromium). Exposes
    # chromiumExtensions.loadArg plus the individual extension packages.
    chromiumExtensions = import ../pkgs/chromium-extensions { pkgs = final; };

    # AI-SLOP Detector: evidence-based static analyzer for AI-generated code
    # slop patterns (empty functions, fake docs, inflated comments, etc.).
    # Free, MIT, fully offline. Exposes the `slop-detector` CLI which the nvim
    # config calls on BufWritePost to produce the lualine `AI-{score}` status
    # and per-file inline diagnostics.
    ai-slop-detector = prev.python3Packages.buildPythonPackage {
      pname = "ai-slop-detector";
      version = "3.10.1";
      src = prev.fetchurl {
        url = "https://files.pythonhosted.org/packages/61/1c/aa467a9b2e18495bb20c25ca010351bf19b379630e24884688daa91a6667/ai_slop_detector-3.10.1.tar.gz";
        hash = "sha256-KFR11bsAtuU317qJFyK4lP61LumhNrpB6afxvdiW8O0=";
      };
      pyproject = true;
      build-system = with prev.python3Packages; [ setuptools ];
      propagatedBuildInputs = with prev.python3Packages; [
        pyyaml radon jinja2 rich pydantic
      ];
      doCheck = false;
    };

    # SynthScan: pattern-based AI-generated code detector. Supports C/C++,
    # Python, JS/TS, Go, Rust, and many other file types via regex patterns.
    # Zero external dependencies, MIT, fully offline. Used for C++ files (.cpp,
    # .cc, .h, .hpp, .cxx) where ai-slop-detector lacks parser support.
    synthscan = prev.python3Packages.buildPythonPackage {
      pname = "synthscan";
      version = "2.0.1";
      src = prev.fetchurl {
        url = "https://files.pythonhosted.org/packages/33/44/b6150a8690fb0294974e44ad52d86a289edaf29ef37de999728bac8fde3c/synthscan-2.0.1-py3-none-any.whl";
        hash = "sha256-5poiFmiNcsnpJB3hEAylY8xuFsGblipf5QUZyKzXqCg=";
      };
      format = "wheel";
      doCheck = false;
    };
  };

  # NUR (Nix User Repository) overlay
  nur = inputs.nur.overlays.default;
}
