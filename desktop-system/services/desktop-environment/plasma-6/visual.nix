{ pkgs, username, ... }:let
  leaf-kde = pkgs.callPackage ./theme/leaf.nix { };
in {
  environment.systemPackages = [
    leaf-kde
    pkgs.papirus-icon-theme
  ];

  home-manager.users.${username} = {
    programs.plasma = {
      workspace = {
        lookAndFeel = "leaf-dark";
        colorScheme = "LeafDark";
        theme = "Leaf";
        widgetStyle = "Leaf";
        windowDecorations.library = "org.kde.kwin.aurorae";
        windowDecorations.theme = "__aurorae__svg__leaf-dark";
        splashScreen.theme = "None";
      };

      kwin = {
        cornerBarrier = false;
        edgeBarrier = 0;

        effects.blur = {
          enable = true;
          strength = 5;
        };
      };
    };
  };
}