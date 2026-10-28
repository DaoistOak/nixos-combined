{ config, pkgs, lib, ... }:
{
  zramSwap = {
    enable = true;
    # Keep zram small: compressed swap lives in RAM, so everything swapped to
    # zram is folded into the hibernation image. With a 30G disk swap
    # partition available, a 1.3G zram still absorbs bursty swap pressure
    # without inflating the image from under-pressure sleep cycles.
    memoryPercent = 10;
    algorithm = "zstd";
    priority = 100;
  };
}
