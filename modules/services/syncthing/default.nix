{ devices ? {}, folders ? {}, serviceLevel ? "user", persistPath ? null }:
if serviceLevel == "system" then
  (import ./system-service.nix { inherit devices folders; })
else
  (import ./user-service.nix { inherit devices folders; })
