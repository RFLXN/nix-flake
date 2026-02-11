{ }:
{ username, ... }: {
  hardware.openrazer = {
    enable = true;
    users = [ username ];
  };
}
