{ enable32Bit ? true }:
{ ... }: {
  hardware.graphics = {
    enable = true;
    enable32Bit = enable32Bit;
  };
}
