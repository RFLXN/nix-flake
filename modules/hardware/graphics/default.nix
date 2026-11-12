{ enable32Bit ? null }:
{ pkgs, ... }: {
  hardware.graphics = {
    enable = true;
    # 32-bit graphics only exists on x86_64; null picks it per platform.
    enable32Bit =
      if enable32Bit != null then enable32Bit else pkgs.stdenv.hostPlatform.isx86_64;
  };
}
