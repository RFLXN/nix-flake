{
  fontSize ? 11,
  font ? "Noto Sans",
  cornerRadius ? 10,
  width ? 350,
  offset ? "15x15"
}:
{ pkgs, username, ... }: {
  home-manager.users.${username}.services.dunst = {
    enable = true;
    settings = {
      global = {
        font = "${font} ${toString fontSize}";
        corner_radius = cornerRadius;
        width = width;
        offset = offset;
        origin = "top-right";
        frame_width = 2;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 10;
        icon_position = "left";
        max_icon_size = 64;
      };
    };
  };
}
