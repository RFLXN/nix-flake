{ devices, folders }:
{ username, ... }: {
  home-manager.users.${username}.services.syncthing = {
    enable = true;

    settings = {
      inherit devices folders;
    };
  };
}
