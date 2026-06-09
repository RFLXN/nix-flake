{
  codexDmgHash ? null,
  codexDmgUrl ? "https://persistent.oaistatic.com/codex-app-prod/Codex.dmg",
  package ? null,
}:
{ lib, pkgs, username, codex-cli-nix, codex-desktop, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  upstreamPackage = codex-desktop.packages.${system}.default;
  patchCodexDmgPackage = pkg:
    let
      codexDmg = pkgs.fetchurl {
        url = codexDmgUrl;
        hash = codexDmgHash;
      };
      oldPayload = pkg.drvAttrs.src;
      oldInstallPhase = oldPayload.drvAttrs.installPhase;
      oldInstallPhaseText = builtins.unsafeDiscardStringContext oldInstallPhase;
      oldInstallPhaseContext = builtins.getContext oldInstallPhase;
      oldCodexDmgContextKeys = builtins.filter
        (key: lib.hasSuffix "-Codex.dmg.drv" key)
        (builtins.attrNames oldInstallPhaseContext);
      installPhaseContext = builtins.removeAttrs oldInstallPhaseContext oldCodexDmgContextKeys;
      codexDmgLine = lib.findFirst
        (line: lib.hasPrefix "cp " line && lib.hasInfix "-Codex.dmg" line)
        (throw "programs.useCodexDesktop: could not find Codex.dmg copy line in upstream payload installPhase.")
        (lib.splitString "\n" oldInstallPhaseText);
      oldCodexDmg = builtins.elemAt (lib.splitString " " codexDmgLine) 1;
      patchedPayload = oldPayload.overrideAttrs (oldAttrs: {
        installPhase = builtins.appendContext
          (builtins.replaceStrings [ oldCodexDmg ] [ "${codexDmg}" ] oldInstallPhaseText)
          installPhaseContext;
      });
    in
    pkg.overrideAttrs (_oldAttrs: {
      src = patchedPayload;
    });
  resolvedPackage =
    if package != null then
      package
    else if codexDmgHash != null then
      patchCodexDmgPackage upstreamPackage
    else
      upstreamPackage;
in
{
  home-manager.users.${username} = {
    imports = [
      codex-desktop.homeManagerModules.default
    ];

    programs.codexDesktopLinux = {
      enable = true;
      package = resolvedPackage;
      remoteControl.package = codex-cli-nix.packages.${system}.default;
    };
  };
}
