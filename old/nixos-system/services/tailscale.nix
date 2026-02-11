{ ... }: {
  services.tailscale = {
    authKeyFile = "/persist/secrets/tailscale.authKey";
  };
}