{
  devices ? {},
  folders ? {},
  serviceLevel ? "user",
  webHost ? "0.0.0.0",
  webPort ? 8384,
  persistPath ? null
}:
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
