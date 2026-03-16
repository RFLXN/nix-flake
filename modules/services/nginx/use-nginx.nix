{
  upstreams ? {},
}:
{ lib, ... }:
{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    inherit upstreams;
  };
}
