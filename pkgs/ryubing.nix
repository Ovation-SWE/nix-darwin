# ryubing.nix
#
# Packages the prebuilt macOS universal .app of Ryubing (the community fork
# that continues Ryujinx after the original was DMCA'd). This does NOT build
# from source — it just fetches the official release archive and drops the
# .app into $out/Applications, which nix-darwin then aliases into
# /Applications/Nix Apps automatically.
#
# Requires: aarch64-darwin (an M-series Mac) or x86_64-darwin. macOS 15+.
#
# ── Filling in the hash ────────────────────────────────────────────────────
# The `hash` below is a placeholder (lib.fakeHash). On first `darwin-rebuild
# switch` the build will fail with:
#     error: hash mismatch ...
#            specified: sha256-AAAA...
#            got:       sha256-<the real one>
# Copy the "got:" value into `hash` and rebuild. Or fetch it ahead of time:
#     nix store prefetch-file --json \
#       https://git.ryujinx.app/Ryubing/Stable/releases/download/1.3.3/ryujinx-1.3.3-macos_universal.app.tar.gz
# ───────────────────────────────────────────────────────────────────────────

{ lib
, stdenvNoCC
, fetchurl
, unzip
}:

let
  # ── Pick your channel/version here ──────────────────────────────────────
  # Stable (recommended to start): repo "Stable", asset "ryujinx-<v>-..."
  # Canary (bleeding edge):        repo "Canary", asset "ryujinx-canary-<v>-..."
  # Always confirm the current version + exact filename on the release page:
  #   https://git.ryujinx.app/Ryubing/Stable/releases
  #   https://git.ryujinx.app/Ryubing/Canary/releases
  channelRepo = "Stable";
  version     = "1.3.3";
  assetName   = "ryujinx-${version}-macos_universal.app.tar.gz";
  # For Canary instead, use:
  #   channelRepo = "Canary";
  #   version     = "1.3.327";
  #   assetName   = "ryujinx-canary-${version}-macos_universal.app.tar.gz";
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ryubing";
  inherit version;

  src = fetchurl {
    url = "https://git.ryujinx.app/Ryubing/${channelRepo}/releases/download/${version}/${assetName}";
    hash = lib.fakeHash; # <-- replace after first build (see header)
  };

  nativeBuildInputs = [ unzip ];

  # Handles either a .tar.gz (current) or a .zip asset, and avoids stdenv
  # trying to cd into the .app bundle as if it were the source root.
  unpackPhase = ''
    runHook preUnpack
    mkdir -p unpacked && cd unpacked
    if [[ "$src" == *.zip ]]; then
      unzip -q "$src"
    else
      tar -xf "$src"
    fi
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    app=$(find . -maxdepth 2 -name '*.app' -type d | head -n1)
    if [[ -z "$app" ]]; then
      echo "error: no .app bundle found in the release archive" >&2
      exit 1
    fi
    mkdir -p "$out/Applications"
    cp -R "$app" "$out/Applications/"
    runHook postInstall
  '';

  # It's a codesigned bundle; don't let Nix strip/rewrite the Mach-O binaries.
  dontFixup = true;

  meta = {
    description = "Ryubing — community fork of the Ryujinx Nintendo Switch emulator";
    homepage = "https://ryujinx.app";
    downloadPage = "https://git.ryujinx.app/Ryubing/${channelRepo}/releases";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    mainProgram = "Ryujinx";
  };
})
