{
  host ? "0.0.0.0",
  port ? 10531,
  version ? "1.0.1",
  authFile ? null,
  models ? null,
  codexVersion ? null,
  baseUrl ? null,
  oauthClientId ? null,
  oauthTokenUrl ? null,
  extraArgs ? [],
}:
{ lib, pkgs, ... }:
let
  args =
    [
      "--yes"
      "openai-oauth@${version}"
      "--host"
      host
      "--port"
      (toString port)
    ]
    ++ lib.optionals (authFile != null) [
      "--oauth-file"
      authFile
    ]
    ++ lib.optionals (models != null) [
      "--models"
      (lib.concatStringsSep "," models)
    ]
    ++ lib.optionals (codexVersion != null) [
      "--codex-version"
      codexVersion
    ]
    ++ lib.optionals (baseUrl != null) [
      "--base-url"
      baseUrl
    ]
    ++ lib.optionals (oauthClientId != null) [
      "--oauth-client-id"
      oauthClientId
    ]
    ++ lib.optionals (oauthTokenUrl != null) [
      "--oauth-token-url"
      oauthTokenUrl
    ]
    ++ extraArgs;

  gptServer = pkgs.writeShellScriptBin "gpt-server" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath [ pkgs.nodejs_24 pkgs.bash pkgs.coreutils ]}:''${PATH:-}"
    exec ${lib.getExe' pkgs.nodejs_24 "npx"} ${lib.escapeShellArgs args} "$@"
  '';
in
{
  assertions = [
    {
      assertion = lib.isString host && host != "";
      message = "programs.useGptOauthServer: host must be a non-empty string.";
    }
    {
      assertion = lib.isInt port && port >= 1 && port <= 65535;
      message = "programs.useGptOauthServer: port must be an integer between 1 and 65535.";
    }
    {
      assertion = models == null || (lib.isList models && lib.all lib.isString models);
      message = "programs.useGptOauthServer: models must be null or a list of strings.";
    }
    {
      assertion = lib.isList extraArgs && lib.all lib.isString extraArgs;
      message = "programs.useGptOauthServer: extraArgs must be a list of strings.";
    }
  ];

  environment.systemPackages = [ gptServer ];
}
