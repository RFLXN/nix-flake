{ persistPath ? null, allowPasswordLogin ? false }:
{ lib, defaultPersistPath ? null, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
in
lib.mkMerge [
  {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = allowPasswordLogin;
        PermitRootLogin = "no";
      };
    };
  }
  (lib.mkIf (path != null) {
    environment.persistence.${path}.files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  })
]
