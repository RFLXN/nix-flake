{ variant ? "main", windowOpacity ? 0.85 }:
{ lib, pkgs, username, ... }:
let
  gtkThemeNames = {
    main = "rose-pine";
    moon = "rose-pine-moon";
    dawn = "rose-pine-dawn";
  };

  transparencyCss = ''
    /* Keep theme palette but allow compositor blur to show through. */
    window.background,
    dialog.background,
    messagedialog.background,
    .background {
      background-color: alpha(@theme_bg_color, ${toString windowOpacity});
    }

    viewport,
    textview,
    scrolledwindow,
    .view {
      background-color: alpha(@theme_base_color, ${toString windowOpacity});
    }
  '';
in
{
  assertions = [
    {
      assertion = builtins.hasAttr variant gtkThemeNames;
      message = "gtk.theme.useRosePine: variant must be one of \"main\", \"moon\", or \"dawn\".";
    }
    {
      assertion = windowOpacity >= 0.0 && windowOpacity <= 1.0;
      message = "gtk.theme.useRosePine: windowOpacity must be between 0.0 and 1.0.";
    }
  ];

  home-manager.users.${username} = {
    gtk = {
      enable = true;
      theme = {
        package = pkgs.rose-pine-gtk-theme;
        name = gtkThemeNames.${variant};
      };
      gtk3.extraCss = lib.optionalString (windowOpacity < 1.0) transparencyCss;
      gtk4.extraCss = lib.optionalString (windowOpacity < 1.0) transparencyCss;
    };
  };
  
}
