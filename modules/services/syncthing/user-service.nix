{
  devices,
  folders,
  webHost ? "127.0.0.1",
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
