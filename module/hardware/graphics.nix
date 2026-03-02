{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # Better for modern Raptor Lake chips
      vpl-gpu-rt # Video Processing Library (QuickSync)
      libvdpau-va-gl
    ];
  };
}
