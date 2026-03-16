{
  port ? 8112,
}: import ./port-redirect-helper.nix {
  path = "/torrent";
  inherit port;
  extraConfig = ''
    proxy_set_header X-Deluge-Base /torrent/;
  '';
}
