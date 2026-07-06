{ timeToScreenOff ? 600, timeToLock ? 900, timeToSuspend ? 1800 }:
{ username, ... }:
{
  home-manager.users.${username}.services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = timeToScreenOff;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = timeToLock;
          on-timeout = "loginctl lock-session && hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = timeToSuspend;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
