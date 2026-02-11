{ }:
{ pkgs, username, ... }:
let
  leaf-kde = pkgs.callPackage ./leaf-pkg.nix { };
in {
  environment.systemPackages = [
    leaf-kde
    pkgs.papirus-icon-theme
  ];

  home-manager.users.${username}.programs.plasma = {
    workspace = {
      lookAndFeel = "leaf-dark";
      colorScheme = "LeafDark";
      theme = "Leaf";
      iconTheme = "Papirus-Dark";
      splashScreen.theme = "None";
      widgetStyle = "Leaf";
      windowDecorations = {
        library = "org.kde.kwin.aurorae";
        theme = "__aurorae__svg__leaf-dark";
      };
    };
  };
}
