{ package ? null }:
{ lib, ... }:
{
  programs.thunderbird = {
    enable = true;
  } // lib.optionalAttrs (package != null) {
    inherit package;
  };
}
