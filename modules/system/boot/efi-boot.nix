{
  canTouchEfiVariables ? false,
}:

{ lib, ... }: {
  boot.loader.efi.canTouchEfiVariables = canTouchEfiVariables;
}
