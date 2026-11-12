{
  devices ? {},
  folders ? {},
  serviceLevel ? "user",
  webHost ? "127.0.0.1",
  webPort ? 8384,
  persistPath ? null
}:
assert
  builtins.elem serviceLevel [ "user" "system" ]
  || throw ''useSyncthing: serviceLevel must be "user" or "system", got "${toString serviceLevel}".'';
if serviceLevel == "system" then
  (import ./system-service.nix {
    inherit
      devices
      folders
      persistPath
      webHost
      webPort
      ;
  })
else
  (import ./user-service.nix {
    inherit
      devices
      folders
      webHost
      webPort
      ;
  })
