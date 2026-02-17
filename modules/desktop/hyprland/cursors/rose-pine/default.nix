{
  cursorSize ? 24
}:
{ pkgs, username, ... }:
{
  environment.sessionVariables = {
    XCURSOR_THEME = "BreezeX-RosePine-Linux";
    XCURSOR_SIZE = toString cursorSize;
    GTK_CURSOR_THEME = "BreezeX-RosePine-Linux";
    GTK_CURSOR_SIZE = toString cursorSize;
    HYPRCURSOR_THEME = "rose-pine-hyprcursor";
    HYPRCURSOR_SIZE = toString cursorSize;
  };

  home-manager.users.${username} = {
    home.packages = [ pkgs.rose-pine-hyprcursor ];

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.rose-pine-cursor;
      name = "BreezeX-RosePine-Linux";
      size = cursorSize;
    };

    wayland.windowManager.hyprland.settings.cursor.enable_hyprcursor = true;
  };
}
