{
  useLogind = { }:
  { ... }:
  {
    services.logind.settings.Login = {
      HandlePowerKey = "suspend";
      HandleLidSwitch = "lock";
      HandleLidSwitchExternalPower = "lock";
      HandleLidSwitchDocked = "lock";
    };
  };
}
