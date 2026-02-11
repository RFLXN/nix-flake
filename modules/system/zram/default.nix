{ memoryPercent ? 25, priority ? 10 }:
{ ... }: {
  zramSwap = {
    enable = true;
    memoryPercent = memoryPercent;
    priority = priority;
  };
}
