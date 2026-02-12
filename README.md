fcfe6b5e8d

chmod +x install.sh
sudo bash ./install.sh

1 manual edit the generated hardware.configuration.nix - it should have no fileSystems -  sudo nano /mnt/etc/nixos/hardware-configuration.nix 
  
  
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



 
 

#2 Install directly from Flake (Impure allows Unfree software)
sudo nixos-install --flake /mnt/etc/nixos#lea-pc --impure --no-root-passwd


#3 Cleanup and Go
sudo umount -R /mnt
reboot


#override from flashdrive to /etc/nixos
sudo cp -rv /run/media/LEA/DISK/nixos-settings/nixos/* /etc/nixos/

sudo cp -rv /home/LEA/Documents/nixos-settings/nixos/* /etc/nixos/


sudo nixos-rebuild build --flake .


#rebuild
 sudo nixos-rebuild switch --flake /etc/nixos#lea-pc --impure




# nixos-settings
