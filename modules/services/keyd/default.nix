{ settings ? {} }:
{ ... }: {
  services.keyd = {
    enable = true;
    keyboards = settings;
  };
}
