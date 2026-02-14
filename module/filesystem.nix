
{ config, lib, pkgs, ... }:

{
  ##############################
  # Root (impermanent)
  ##############################
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=8G" "mode=755" ];
  };

  ##############################
  # Nix store
  ##############################
  fileSystems."/nix" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress=zstd" "noatime" ];
  };

  ##############################
  # Persistent state
  ##############################
  fileSystems."/persist" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "subvol=persist" "compress=zstd" "noatime" ];
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
  # Memory & Swap Optimizations
  ##############################
  
  # zRAM configuration
  zramSwap = {
    enable = true;
    memoryPercent = 70; 
    priority = 100;    
  };

  # Physical Swap (Last resort/Safety net)
  swapDevices = [{ 
    device = "/persist/swap/swapfile"; 
    priority = 0; 
  }];

    boot.kernel.sysctl = {
    "vm.swappiness" = 5; 
    "vm.vfs_cache_pressure" = 50; 

"fs.inotify.max_user_watches" = 524288;

  };

}



    
  
  

