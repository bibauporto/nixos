{
  pkgs,
  inputs,
  lib,
  ...
}:

let
  # Optimization: Define the kernel here to keep the boot block clean
  cachyKernel =
    inputs.nix-cachyos-kernel.packages.${pkgs.stdenv.hostPlatform.system}.linux-cachyos-latest-x86_64-v3;
in
{
  boot = {
    kernelPackages = pkgs.linuxPackagesFor cachyKernel;

    loader.timeout = 0;
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = lib.mkForce false;

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    # TPM2 & Silent Boot
    initrd.systemd.enable = true;
    initrd.luks.devices."cryptroot".crypttabExtraOpts = [ "tpm2-device=auto" ];

    # Combined Silent Boot Params
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
}
