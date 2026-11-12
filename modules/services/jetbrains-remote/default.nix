{ ides ? [] }:
{ username, ... }: {
  home-manager.users.${username}.programs.jetbrains-remote = {
    enable = true;
    inherit ides;
  };
}
