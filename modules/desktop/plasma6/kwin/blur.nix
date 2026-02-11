{ strength ? 5 }:
{ username, ... }: {
  home-manager.users.${username}.programs.plasma.kwin.effects.blur = {
    enable = true;
    inherit strength;
  };
}
