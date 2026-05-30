{ settings ? {}, enableDefaultConfig ? false }:
{ lib, username, ... }:
let
  defaultSettings = lib.optionalAttrs (!enableDefaultConfig) {
    "*" = {
      ForwardAgent = false;
      AddKeysToAgent = "no";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
    };
  };
in
{
  home-manager.users.${username}.programs.ssh = {
    enable = true;
    inherit enableDefaultConfig;
    settings = defaultSettings // settings;
  };
}
