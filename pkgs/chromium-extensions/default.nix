# Chromium extensions, packaged as unpacked directories for `--load-extension`.
#
# Why not the Chrome Web Store: ungoogled-chromium cannot complete the store's
# signed-blob install flow, and the legacy CRX endpoint
# (clients2.google.com/service/update2/crx) now answers 204/404 for almost
# everything, so `programs.chromium.extensions` has nothing to install from.
# Upstream release assets are used instead.
#
# Pins live in src/extensions.json (machine-edited by `updt ext`): upstream repo,
# release tag, resolved asset name and SRI hash. Extensions that talk native
# messaging additionally carry a throwaway public `key`; without a key Chromium
# derives the extension id from the absolute path, which changes on every
# rebuild, and native messaging hosts only answer ids listed in allowed_origins
# (see modules/system/config/browser/default.nix).
{ pkgs }:

let
  inherit (pkgs) lib;

  pins = builtins.fromJSON (builtins.readFile ./src/extensions.json);

  mkExtension =
    {
      name,
      description ? name,
      version,
      url,
      hash,
      key ? null,
      extensionId ? null,
      # owner/repo/tag/asset/source are updater metadata (see src/extensions.json).
      ...
    }:
    pkgs.stdenvNoCC.mkDerivation {
      pname = "chromium-extension-${name}";
      inherit description version;
      src = pkgs.fetchurl { inherit url hash; };
      # Upstream layouts differ (root files vs. a nested build dir vs. a source
      # tarball), so keep the unpacked tree as-is and pick the extension dir below.
      sourceRoot = ".";
      strictDeps = true;
      nativeBuildInputs = [
        pkgs.python3
        pkgs.unzip
      ];

      # Layouts differ between upstreams (some nest the build dir, KDE ships a
      # source tarball), so locate the single manifest instead of guessing paths.
      installPhase = ''
        runHook preInstall

        mkdir -p "$out"
        manifests="$(find . -maxdepth 4 -name manifest.json)"
        count="$(printf '%s\n' "$manifests" | grep -c . || true)"
        if [ "$count" -ne 1 ]; then
          echo "expected exactly one manifest.json, found $count" >&2
          printf '%s\n' "$manifests" >&2
          exit 1
        fi
        cp -r "$(dirname "$manifests")"/. "$out/"

        ${
          if key == null then
            ""
          else
            ''
              key='${key}'
              extension_id='${if extensionId == null then "" else extensionId}'
              python3 - "$out/manifest.json" "$key" "$extension_id" <<'PY'
              import base64
              import hashlib
              import json
              import sys

              manifest, key, expected = sys.argv[1:4]

              with open(manifest) as handle:
                  parsed = json.load(handle)
              parsed["key"] = key
              with open(manifest, "w") as handle:
                  json.dump(parsed, handle, indent=2)

              digest = hashlib.sha256(base64.b64decode(key)).hexdigest()[:32]
              actual = "".join(chr(ord("a") + int(digit, 16)) for digit in digest)
              if expected and actual != expected:
                  raise SystemExit(f"extension id mismatch: {actual} != {expected}")
              print(f"injected key, extension id: {actual}")
              PY
            ''
        }

        test -f "$out/manifest.json"
        runHook postInstall
      '';

      passthru = {
        inherit extensionId key;
        host = if extensionId == null then null else "chrome-extension://${extensionId}/";
      };

      meta = {
        description = "Unpacked Chromium extension: ${description}";
        homepage = "https://github.com/";
        platforms = lib.platforms.unix;
      };
    };

  extensions = lib.mapAttrs (name: pin: mkExtension (pin // { inherit name; })) pins // {
    # Local, not from upstream: Chromium has no Firefox-style user.css support
    # (the binary has no --user-style-sheet switch), so inject src/user.css into
    # every page instead. Costs one content script per frame.
    userStyles = pkgs.stdenvNoCC.mkDerivation {
      pname = "chromium-extension-userStyles";
      version = "1";
      dontBuild = true;
      dontUnpack = true;
      installPhase = ''
        runHook preInstall
        mkdir -p "$out"
        cp ${./src/user.css} "$out/user.css"
        cat >"$out/manifest.json" <<'JSON'
        {
          "manifest_version": 3,
          "name": "User CSS",
          "version": "1.0",
          "description": "Injects user.css into every page",
          "content_scripts": [
            {
              "matches": ["<all_urls>"],
              "css": ["user.css"],
              "run_at": "document_start",
              "all_frames": true
            }
          ]
        }
        JSON
        runHook postInstall
      '';
      passthru.extensionId = null;
    };
  };
in
rec {
  inherit extensions pins;

  # Attribute names, e.g. ["darkReader" "stylus"], for the updater script.
  names = lib.attrNames extensions;

  # Value for the browser's --load-extension flag (comma-separated store paths).
  loadArg =
    "--load-extension=" + lib.concatMapStringsSep "," (ext: ext.outPath) (lib.attrValues extensions);

  # Every extension that needs a native messaging host, with its store path.
  nativeMessagingHosts = lib.filterAttrs (_: ext: ext.extensionId != null) extensions;
}
