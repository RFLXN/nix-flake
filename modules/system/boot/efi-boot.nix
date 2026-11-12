{
  canTouchEfiVariables ? false,
}:

{ ... }: {
  boot.loader.efi.canTouchEfiVariables = canTouchEfiVariables;
}
