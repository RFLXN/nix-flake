{ lib, stdenvNoCC, fetchurl, version ? "0.101.0", codexHashes ? {
    x86_64-linux = "sha256-/zY/hZfb8Dg8F2WefJJzW6qZG+irmflnxcw8aLMpJ3w=";
    aarch64-linux = lib.fakeSha256;
    x86_64-darwin = lib.fakeSha256;
    aarch64-darwin = lib.fakeSha256;
  } }:
let
  system = stdenvNoCC.hostPlatform.system;
  platforms = {
    x86_64-linux = "x86_64-unknown-linux-musl";
    aarch64-linux = "aarch64-unknown-linux-musl";
    x86_64-darwin = "x86_64-apple-darwin";
    aarch64-darwin = "aarch64-apple-darwin";
  };
  platform = platforms.${system} or (throw "codex: unsupported system ${system}");
  sha256 = codexHashes.${system} or lib.fakeSha256;
in stdenvNoCC.mkDerivation {
  pname = "codex";
  inherit version;

  src = fetchurl {
    url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-${platform}.tar.gz";
    inherit sha256;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    tar -xzf $src
    install -m 755 codex-${platform} $out/bin/codex
    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenAI Codex CLI";
    homepage = "https://github.com/openai/codex";
    license = licenses.asl20;
    mainProgram = "codex";
    platforms = builtins.attrNames platforms;
  };
}
