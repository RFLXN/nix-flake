{
  commandLineArgs ? [],
  language ? "ko-KR",
  languageEnvironment ? null,
}:
{ lib, pkgs, ... }:
let
  chromiumBase = pkgs.chromium.override {
    commandLineArgs =
      commandLineArgs
      ++ lib.optionals (language != null) [ "--lang=${language}" ];
  };
  resolvedLanguageEnvironment =
    if language == null then
      null
    else if languageEnvironment != null then
      languageEnvironment
    else
      let
        primaryLanguage = builtins.head (lib.splitString "-" language);
        localeLanguage = lib.replaceStrings [ "-" ] [ "_" ] language;
      in
      "${localeLanguage}:${primaryLanguage}";
  chromiumPackage =
    if resolvedLanguageEnvironment == null then
      chromiumBase
    else
      pkgs.symlinkJoin {
        name = "${chromiumBase.name}-localized";
        paths = [ chromiumBase ];
        nativeBuildInputs = [ pkgs.makeWrapper ];

        postBuild = ''
          rm -f "$out/bin/chromium" "$out/bin/chromium-browser"
          makeWrapper ${chromiumBase}/bin/chromium "$out/bin/chromium" \
            --set LANGUAGE ${lib.escapeShellArg resolvedLanguageEnvironment}
          ln -s "$out/bin/chromium" "$out/bin/chromium-browser"
        '';
      };
in
{
  programs.chromium.enable = true;
  environment.systemPackages = [ chromiumPackage ];
}
