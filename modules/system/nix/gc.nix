{ dates, options ? "--delete-older-than 30d" }:
{ ... }: {
  nix.gc = {
    automatic = true;
    inherit dates options;
  };
}
