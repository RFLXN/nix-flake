{ username, ... }: {
  home-manager.users.${username} = {
    programs.plasma = {
      panels = [
        {
          alignment = "center";
          floating = true;
          height = 60;
          hiding = "none";
          lengthMode = "fit";
          location = "bottom";
          opacity = "translucent";
          screen = 0;
          widgets = [
            {
              name = "org.kde.plasma.kickoff";
              config = { General.icon = "nix-snowflake"; };
            }
            {
              name = "org.kde.plasma.icontasks";
              config = { General.launchers = "preferred://browser,preferred://filemanager,applications:discord.desktop,file:///nix/store/k3xii2mllpr464240ijfy01yk5535rq1-system-path/share/applications/steam.desktop,file:///nix/store/k3xii2mllpr464240ijfy01yk5535rq1-system-path/share/applications/spotify.desktop,applications:kitty.desktop,applications:systemsettings.desktop";};
            }
            "org.kde.plasma.minimizeall"
          ];
        }
        {
          alignment = "center";
          floating = false;
          height = 40;
          hiding = "none";
          lengthMode = "fill";
          location = "bottom";
          opacity = "opaque";
          screen = 1;
          widgets = [
            {
              name = "org.kde.plasma.digitalclock";
              config = { Appearance.dateFormat = "isoDate"; };
            }
            "org.kde.plasma.panelspacer"
            {
              name = "org.kde.plasma.systemtray";
            }
          ];
        }
      ];
    };
  };
}