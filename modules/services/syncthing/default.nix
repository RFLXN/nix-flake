{ devices ? {}, folders ? {}, serviceLevel ? "user", persistPath ? null }:
if serviceLevel == "system" then
  (import ./system-service.nix { inherit devices folders persistPath; })
else
  (import ./user-service.nix { inherit devices folders; })
