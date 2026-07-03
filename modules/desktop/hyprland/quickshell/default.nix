{
  configs ? null,
  package ? null,
  quickshellPackage ? null,
  runtimePackages ? null,
  systemdTarget ? null,
}:
{ lib, rflxn-shell, username, ... }:
let
  quickShellConfig =
    {
      enable = true;
    }
    // lib.optionalAttrs (configs != null) {
      inherit configs;
    }
    // lib.optionalAttrs (package != null) {
      inherit package;
    }
    // lib.optionalAttrs (quickshellPackage != null) {
      inherit quickshellPackage;
    }
    // lib.optionalAttrs (runtimePackages != null) {
      inherit runtimePackages;
    }
    // lib.optionalAttrs (systemdTarget != null) {
      inherit systemdTarget;
    };
in
{
  imports = [ rflxn-shell.nixosModules.default ];

  home-manager.users.${username}.services.rflxn-shell = quickShellConfig;
}
