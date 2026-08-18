{ }:
{ lib, pkgs, ... }:
let
  version = "0.2.10";
  platformSources = {
    "x86_64-linux" = {
      npmArch = "x64";
      hash = "sha256-vrSmS4r+NxRQGRmsDLm6cJkj9+ZuFYVzhSah5AFbIxo=";
    };
    "aarch64-linux" = {
      npmArch = "arm64";
      hash = "sha256-/+CiaJsdulXo88qTSfIkgDUQ3IMVLaTJo2U0Bk9HEqs=";
    };
  };
  system = pkgs.stdenv.hostPlatform.system;
  platform =
    platformSources.${system}
      or (throw "programs.useCodexAuth: unsupported platform ${system}");

  codexAuth = pkgs.stdenv.mkDerivation {
    pname = "codex-auth";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@loongphy/codex-auth-linux-${platform.npmArch}/-/codex-auth-linux-${platform.npmArch}-${version}.tgz";
      inherit (platform) hash;
    };
    sourceRoot = "package";

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.makeWrapper
    ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 bin/codex-auth "$out/libexec/codex-auth"
      makeWrapper "$out/libexec/codex-auth" "$out/bin/codex-auth" \
        --set CODEX_AUTH_NODE_EXECUTABLE ${lib.getExe pkgs.nodejs_24} \
        --prefix PATH : ${lib.makeBinPath [ pkgs.nodejs_24 pkgs.curl ]}

      runHook postInstall
    '';

    meta = {
      description = "CLI tool to switch and manage Codex accounts";
      homepage = "https://github.com/loongphy/codex-auth";
      license = lib.licenses.mit;
      mainProgram = "codex-auth";
      platforms = builtins.attrNames platformSources;
    };
  };
in
{
  environment.systemPackages = [ codexAuth ];
}
