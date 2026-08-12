{ timeToScreenOff ? 600, timeToLock ? 900, timeToSuspend ? 1800 }:
{ username, ... }:
{
  home-manager.users.${username}.services.hypridle = {
    enable = true;

    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
      };

      listener = [
        {
          timeout = timeToScreenOff;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
        }
        {
          timeout = timeToLock;
          on-timeout = "loginctl lock-session && hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
        }
        {
          timeout = timeToSuspend;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
