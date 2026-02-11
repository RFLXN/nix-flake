{ ... }: {
  services.openssh = {
    extraConfig = ''
      PermitRootLogin no
      PasswordAuthentication yes
    '';
  };
}