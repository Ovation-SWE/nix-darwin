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
# ── Updating ───────────────────────────────────────────────────────────────
# 1. Check latest release at https://git.ryujinx.app/Ryubing/Canary/releases
# 2. Update `version` and `assetName` below
# 3. Prefetch the new hash:
#      nix store prefetch-file --json \
#        https://git.ryujinx.app/Ryubing/Canary/releases/download/<ver>/ryujinx-canary-<ver>-macos_universal.app.tar.gz
# 4. Replace `hash` with the "hash" value from the output
# ───────────────────────────────────────────────────────────────────────────

{ lib
, stdenvNoCC
, fetchurl
, unzip
}:

let
  version   = "1.3.328";
  assetName = "ryujinx-canary-${version}-macos_universal.app.tar.gz";
in
stdenvNoCC.mkDerivation {
  pname = "ryubing";
  inherit version;

  src = fetchurl {
    url  = "https://git.ryujinx.app/Ryubing/Canary/releases/download/${version}/${assetName}";
    hash = "sha256-mt1Z6xVauPeDfUxEwElozPM4NAxHR4MyyrSJ9Xd9nw8=";
  };

  nativeBuildInputs = [ unzip ];

  # Avoids stdenv trying to cd into the .app bundle as if it were the source root.
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

  # Codesigned bundle — don't let Nix strip/rewrite the Mach-O binaries.
  dontFixup = true;

  meta = {
    description = "Ryubing — community fork of the Ryujinx Nintendo Switch emulator";
    homepage    = "https://ryujinx.app";
    downloadPage = "https://git.ryujinx.app/Ryubing/Canary/releases";
    license     = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms   = [ "aarch64-darwin" "x86_64-darwin" ];
    mainProgram = "Ryujinx";
  };
}
