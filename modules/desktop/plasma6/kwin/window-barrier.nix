{ }:
{ username, ... }: {
  home-manager.users.${username}.programs.plasma.kwin = {
    cornerBarrier = false;
    edgeBarrier = 0;
  };
}
