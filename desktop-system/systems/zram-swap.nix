{ ... }: {
  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 10;
  };
}