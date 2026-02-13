# nixos-settings

## Installation

### 0. Pre-requisites

```bash
chmod +x install.sh
sudo bash ./install.sh
```

### 1. Manual Hardware Configuration

Edit the generated `hardware-configuration.nix`. It should have no `fileSystems`.

```bash
sudo nano /mnt/etc/nixos/hardware-configuration.nix
```

Example configuration:

```nix
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  ##############################
  # Kernel / hardware detection
  ##############################

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-inter" ]; 
  boot.extraModulePackages = [ ];

  ##############################
  # Disk encryption (KEEP THIS)
  ##############################

  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/nvme0n1p2";
    preLVM = true;
  };
}
```

### 2. Install directly from Flake

Impure allows Unfree software.

```bash
sudo nixos-install --flake /mnt/etc/nixos#lea-pc --impure --no-root-passwd
```

### 3. Cleanup and Go

```bash
sudo umount -R /mnt
reboot
```

