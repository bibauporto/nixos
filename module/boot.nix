{ pkgs, nix-cachyos-kernel, ... }:

{
  # 1. Apply the overlay so pkgs.cachyosKernels is recognized
  nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];

  boot = {
    # 2. Select the CachyOS v3 kernel
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;

    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };

    loader.timeout = 0; 

    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "boot.shell_on_fail"
    ];

    plymouth.enable = true;
    consoleLogLevel = 0;
    initrd.verbose = false;
  };

  # 3. BINARY CACHE: Crucial so you don't compile locally
  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://attic.xuyh0120.win/lantian"
      "https://cache.garnix.io"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
}