{ ... }:
{ username, ... }:
{
  home-manager.users.${username} = {
    services.snixembed.enable = true;
  };
}
