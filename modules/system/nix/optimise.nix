{ dates }:
{ ... }: {
  nix.optimise = {
    automatic = true;
    inherit dates;
  };
}
