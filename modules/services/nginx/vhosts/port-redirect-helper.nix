{
  host ? "localhost",
  path,
  port,
  upstreamHost ? "127.0.0.1",
  default ? false,
  proxyWebsockets ? true,
  forwardPrefixHeader ? true,
  recommendedProxySettings ? true,
  extraConfig ? "",
}:
{ lib, ... }:
let
  withLeadingSlash =
    if path == "" then
      "/"
    else if builtins.substring 0 1 path == "/" then
      path
    else
      "/${path}";

  withoutTrailingSlash =
    if withLeadingSlash == "/" then
      "/"
    else if builtins.substring ((builtins.stringLength withLeadingSlash) - 1) 1 withLeadingSlash == "/" then
      builtins.substring 0 ((builtins.stringLength withLeadingSlash) - 1) withLeadingSlash
    else
      withLeadingSlash;

  normalizedPath =
    if withoutTrailingSlash == "/" then "/"
    else "${withoutTrailingSlash}/";

  upstream =
    if normalizedPath == "/" then
      "http://${upstreamHost}:${toString port}"
    else
      "http://${upstreamHost}:${toString port}/";

  locationExtraConfig =
    (if forwardPrefixHeader && normalizedPath != "/" then
      "proxy_set_header X-Forwarded-Prefix ${normalizedPath};\n"
    else
      "")
    + extraConfig;
in
{
  services.nginx.virtualHosts.${host} = lib.mkMerge [
    (lib.optionalAttrs default {
      default = true;
    })
    {
      locations =
        if normalizedPath == "/" then
          {
            "/" = {
              inherit proxyWebsockets;
              proxyPass = upstream;
              inherit recommendedProxySettings;
              inherit extraConfig;
            };
          }
        else
          {
            "= ${withoutTrailingSlash}" = {
              return = "301 ${normalizedPath}";
            };

            "${normalizedPath}" = {
              inherit proxyWebsockets;
              proxyPass = upstream;
              inherit recommendedProxySettings;
              extraConfig = locationExtraConfig;
            };
          };
    }
  ];
}
