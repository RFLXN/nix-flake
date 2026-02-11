{ hashedPassword ? null, hashedPasswordFile ? null, extraGroups ? [] }:
{ username, ... }: {
  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ] ++ extraGroups;
    inherit hashedPassword hashedPasswordFile;
  };
}