{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  fzf,
  bat,
  fd,
  version ? "2.6.0",
  forgeHashes ? {
    x86_64-linux = "sha256-hAwVJGPuU6VyD604l5jSL2R+4rkphTcQVKOAKzIQKIc=";
    aarch64-linux = "sha256-RS4rAhXkUVIDTxtLqBu2bnAvboA6nDU0h1R5E2wUHHk=";
    x86_64-darwin = "sha256-56+/ijwUdQoPCapx7ZF9qXcXLC0LtFLJGdzG0Nr+10w=";
    aarch64-darwin = "sha256-K/NwKYsnzYfOqPBKYB0Z8aUN5GJTy03dKNw0JtfPkjA=";
  },
}:
let
  system = stdenvNoCC.hostPlatform.system;
  targets = {
    x86_64-linux = "x86_64-unknown-linux-musl";
    aarch64-linux = "aarch64-unknown-linux-musl";
    x86_64-darwin = "x86_64-apple-darwin";
    aarch64-darwin = "aarch64-apple-darwin";
  };
  target =
    targets.${system}
      or (throw "forgecode: unsupported system ${system}");
  hash =
    forgeHashes.${system}
      or (throw "forgecode: missing hash for system ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "forgecode";
  inherit version;

  src = fetchurl {
    url = "https://github.com/antinomyhq/forgecode/releases/download/v${version}/forge-${target}";
    inherit hash;
  };

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec
    install -m 755 $src $out/libexec/forge

    makeWrapper $out/libexec/forge $out/bin/forge \
      --prefix PATH : ${lib.makeBinPath [ fzf bat fd ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "AI-enabled pair programmer for Claude, GPT, Grok, Gemini, and more";
    homepage = "https://forgecode.dev";
    license = licenses.asl20;
    mainProgram = "forge";
    platforms = builtins.attrNames targets;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
