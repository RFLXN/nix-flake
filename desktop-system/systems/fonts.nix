{ pkgs, ... }: {
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      fira-code
      nanum
      noto-fonts
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
        monospace = [ "Fira Code" "Noto Sans" ];
      };
    };
  };
}