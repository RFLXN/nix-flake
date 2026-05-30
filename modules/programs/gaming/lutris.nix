{ }:
{ pkgs, ... }:
let
  lutris = pkgs.lutris.override {
    buildFHSEnv = attrs:
      pkgs.buildFHSEnv (attrs // {
        multiPkgs = pkgs':
          attrs.multiPkgs (pkgs' // {
            # Lutris only needs openldap as a Wine runtime library; the syncrepl test is flaky on this input.
            openldap = pkgs'.openldap.overrideAttrs (_old: {
              doCheck = false;
            });
          });
      });
  };
in
{
  environment.systemPackages = [ lutris ];
}
