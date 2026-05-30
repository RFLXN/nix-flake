{
  hashedPassword ? null,
  hashedPasswordFile ? null,
  rootHashedPassword ? null,
  rootHashedPasswordFile ? null,
  extraGroups ? [],
}:
{ lib, username, ... }: {
  users.mutableUsers = false;
  users.users =
    {
      ${username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ] ++ extraGroups;
        inherit hashedPassword hashedPasswordFile;
      };
    }
    // lib.optionalAttrs (rootHashedPassword != null || rootHashedPasswordFile != null) {
      root = {
        hashedPassword = rootHashedPassword;
        hashedPasswordFile = rootHashedPasswordFile;
      };
    };
}
