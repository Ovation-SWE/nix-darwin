# Fetches the prebuilt macOS universal .app from the Ryubing Canary releases
# and places it in $out/Applications so nix-darwin links it into
# /Applications/Nix Apps (making it visible in Spotlight and the app launcher).
#
# The nixpkgs `ryubing` package builds from source and produces a CLI binary
# only — no .app bundle — which is why we maintain this separately.
#
# ── Updating ───────────────────────────────────────────────────────────────
# 1. Check https://git.ryujinx.app/Ryubing/Canary/releases for the latest tag
# 2. Update `version` below
# 3. Prefetch the new hash:
#      nix store prefetch-file --json \
#        https://git.ryujinx.app/Ryubing/Canary/releases/download/<ver>/ryujinx-canary-<ver>-macos_universal.app.tar.gz
# 4. Replace `hash` with the "hash" value from the output
# ───────────────────────────────────────────────────────────────────────────

{ lib
, stdenvNoCC
, fetchurl
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

  dontUnpack = false;

  unpackPhase = ''
    runHook preUnpack
    mkdir -p unpacked && cd unpacked
    tar -xf "$src"
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
    description  = "Ryubing — community fork of the Ryujinx Nintendo Switch emulator";
    homepage     = "https://ryujinx.app";
    downloadPage = "https://git.ryujinx.app/Ryubing/Canary/releases";
    license      = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms    = [ "aarch64-darwin" "x86_64-darwin" ];
    mainProgram  = "Ryujinx";
  };
}
