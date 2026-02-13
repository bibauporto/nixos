{ pkgs, nix-cachyos-kernel, ... }:

{
  # Apply the overlay to make pkgs.cachyosKernels available
  nixpkgs.overlays = [ nix-cachyos-kernel.overlays.pinned ];

  boot = {
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;
    # kernelPackages = pkgs.linuxPackages_latest;

    # EFI settings
    loader.efi.canTouchEfiVariables = true;

    # Systemd-boot specific settings
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };

    # Hidden menu timeout
    loader.timeout = 0;

    # Kernel Parameters for a "Silent" experience
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "boot.shell_on_fail"
    ];

    # Plymouth provides the graphical logo and decryption prompt
    plymouth.enable = true;

    # Clean up the console output
    consoleLogLevel = 0;
    initrd.verbose = false;
  };
}
