{ prefix ? "hyprland-" }:
{ username, ... }: {
  environment.sessionVariables.XDG_MENU_PREFIX = prefix;

  home-manager.users.${username}.xdg.configFile."menus/${prefix}applications.menu" = {
    force = true;
    text = ''
      <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
        "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">

      <Menu>
        <Name>Applications</Name>
        <DefaultAppDirs/>
        <DefaultDirectoryDirs/>
        <DefaultMergeDirs/>

        <Include>
          <All/>
        </Include>
      </Menu>
    '';
  };
}
