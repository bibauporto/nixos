{ config, lib, pkgs, ... }:

{
  ##############################
  # Root (impermanent)
  ##############################

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "size=8G"
      "mode=755"
    ];
  };

  ##############################
  # Nix store
  ##############################

  fileSystems."/nix" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "compress=zstd"
      "noatime"
    ];
  };

  ##############################
  # Persistent state
  ##############################

  fileSystems."/persist" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [
      "subvol=persist"
      "compress=zstd"
      "noatime"
    ];
    neededForBoot = true;
  };

  ##############################
  # EFI boot
  ##############################

  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";
    # device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  ##############################
  # Swap (btrfs-safe)
  ##############################

  # Enable zRAM swap
  zramSwap.enable = true;
  
  # How much of your 16GB to dedicate to the zRAM device
  # 50% to 100% is common; it only uses RAM when data is actually in it
  zramSwap.memoryPercent = 70; 

  # Optimization: Tell the kernel to prefer zRAM over the SSD swap
  # By setting a higher priority (e.g., 100) than the SSD swap (usually -2)
  zramSwap.priority = 100;


  swapDevices = [
    { device = "/persist/swap/swapfile";
priority = 0;
 }
  ];
}

