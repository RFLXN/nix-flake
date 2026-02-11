{ dates }:
{ ... }: {
  nix.gc = {
    automatic = true;
    inherit dates;
  };
}
