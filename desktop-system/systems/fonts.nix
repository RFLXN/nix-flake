{ pkgs, ... }:
let
  # Custom fontconfig for language-specific CJK fonts
  fontconfigConf = pkgs.writeText "99-cjk-fonts.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <!-- Korean (ko) -> Noto Sans CJK KR -->
      <match target="pattern">
        <test name="lang" compare="contains">
          <string>ko</string>
        </test>
        <test name="family">
          <string>sans-serif</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Noto Sans CJK KR</string>
        </edit>
      </match>

      <match target="pattern">
        <test name="lang" compare="contains">
          <string>ko</string>
        </test>
        <test name="family">
          <string>serif</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Noto Serif CJK KR</string>
        </edit>
      </match>

      <!-- Japanese (ja) -> Noto Sans CJK JP -->
      <match target="pattern">
        <test name="lang" compare="contains">
          <string>ja</string>
        </test>
        <test name="family">
          <string>sans-serif</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Noto Sans CJK JP</string>
        </edit>
      </match>

      <match target="pattern">
        <test name="lang" compare="contains">
          <string>ja</string>
        </test>
        <test name="family">
          <string>serif</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>Noto Serif CJK JP</string>
        </edit>
      </match>
    </fontconfig>
  '';

  fontconfigPkg = pkgs.runCommand "fontconfig-cjk-lang" {} ''
    mkdir -p $out/etc/fonts/conf.d
    ln -s ${fontconfigConf} $out/etc/fonts/conf.d/99-cjk-fonts.conf
  '';
in
{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      fira-code
      nanum
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Noto Sans" "Noto Sans CJK KR" "Noto Sans CJK JP" ];
        serif = [ "Noto Serif" "Noto Serif CJK KR" "Noto Serif CJK JP" ];
        monospace = [ "Fira Code" "Noto Sans Mono CJK KR" "Noto Sans Mono CJK JP" ];
      };

      confPackages = [ fontconfigPkg ];
    };
  };
}