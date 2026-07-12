{ trustedInterfaces ? [] }:
{ ... }:
{
  networking.firewall = {
    enable = true;
    inherit trustedInterfaces;
  };
}
