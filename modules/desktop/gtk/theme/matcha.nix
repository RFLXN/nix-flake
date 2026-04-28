{ color ? "dark", variant ? "azul", windowOpacity ? 0.85 }:
{ lib, pkgs, username, ... }:
let
  colors = {
    standard = "Matcha";
    light = "Matcha-light";
    dark = "Matcha-dark";
  };
  variants = [ "aliz" "azul" "pueril" "sea" ];
  theme = {
    package = pkgs.matcha-gtk-theme;
    name = "${colors.${color}}-${variant}";
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
      assertion = builtins.hasAttr color colors;
      message = "gtk.theme.useMatcha: color must be one of \"standard\", \"light\", or \"dark\".";
    }
    {
      assertion = builtins.elem variant variants;
      message = "gtk.theme.useMatcha: variant must be one of \"aliz\", \"azul\", \"pueril\", or \"sea\".";
    }
    {
      assertion = windowOpacity >= 0.0 && windowOpacity <= 1.0;
      message = "gtk.theme.useMatcha: windowOpacity must be between 0.0 and 1.0.";
    }
  ];

  home-manager.users.${username}.gtk = {
    enable = true;
    inherit theme;
    gtk4.theme = theme;
    gtk3.extraCss = lib.optionalString (windowOpacity < 1.0) transparencyCss;
    gtk4.extraCss = lib.optionalString (windowOpacity < 1.0) transparencyCss;
  };
}
