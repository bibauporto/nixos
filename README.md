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
Now we need to generate the keys in that location. Please run:
sudo nix run nixpkgs#sbctl -- create-keys
After the keys are created, you can apply the configuration:
nswitch
Apply the configuration:
        sudo nixos-rebuild switch --flake .#lea-pc
    
2.  Generate and Enroll Secure Boot Keys:
    *   Note: Ensure your BIOS is in "Setup Mode" (Secure Boot enabled but keys cleared) if this is a fresh setup, or just run these if you are adding custom keys.
        sudo sbctl create-keys
    sudo sbctl enroll-keys --microsoft
        The --microsoft flag is recommended to ensure third-party hardware (like GPUs) continues to work.
3.  Enroll the TPM2 Key for Disk Unlocking:
    This binds your disk encryption to the Secure Boot state (PCR 7).
        sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcr=7 /dev/disk/by-uuid/2a77d2e1-195b-4b1d-b3d3-b7288973cf63