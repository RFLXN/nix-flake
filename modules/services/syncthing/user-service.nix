{
  devices,
  folders,
  webHost ? "0.0.0.0",
  webPort ? 8384
}:
{ username, ... }: {
  home-manager.users.${username}.services.syncthing = {
    enable = true;
    guiAddress = "${webHost}:${toString webPort}";

    settings = {
      inherit devices folders;
    };
  };
}
