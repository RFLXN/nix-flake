{ persistPath ? null, allowPasswordLogin ? false }:
{ defaultPersistPath, ... }:
let
  path = if persistPath != null then persistPath else defaultPersistPath;
in
{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = allowPasswordLogin;
      # Keyboard-interactive goes through PAM and would still accept passwords.
      KbdInteractiveAuthentication = allowPasswordLogin;
      PermitRootLogin = "no";
    };
  };

  environment.persistence.${path}.files = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_ed25519_key.pub"
    "/etc/ssh/ssh_host_rsa_key"
    "/etc/ssh/ssh_host_rsa_key.pub"
  ];
}
