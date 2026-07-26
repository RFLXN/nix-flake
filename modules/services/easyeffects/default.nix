{
  preset ? "",
  extraPresets ? { },
}:
{ config, username, ... }:
{
  assertions = [
    {
      assertion = config.services.pipewire.enable;
      message = "useEasyEffects requires services.pipewire.enable.";
    }
  ];

  programs.dconf.enable = true;

  home-manager.users.${username}.services.easyeffects = {
    enable = true;
    inherit preset extraPresets;
  };
}
