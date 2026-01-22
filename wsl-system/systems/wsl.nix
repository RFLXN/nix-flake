{ config, username, ... }: { 
  wsl.enable = true;
  wsl.defaultUser = username;

  wsl.wslConf = {
    user.default = username;

    automount = {
      enabled = true;
      ldconfig = false;
      mountFsTab = false;
      options = "metadata,uid=1000,gid=100";
      root = "/mnt";
    };

    boot = {
      command = "";
      systemd = true;
    };

    interop = {
      enabled = true;
      appendWindowsPath = true;
    };

    network = {
      generateHosts = true;
      generateResolvConf = true;
      hostname = config.networking.hostName;
    };
  };
}