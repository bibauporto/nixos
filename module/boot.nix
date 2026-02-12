{ pkgs, ... }:

{
  boot = {
    # 1. EFI settings (Global for loaders)
    loader.efi.canTouchEfiVariables = true;

    # 2. Systemd-boot specific settings
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };

    # 3. Hidden menu timeout
    loader.timeout = 0; 

    # 4. Kernel Parameters for a "Silent" experience
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