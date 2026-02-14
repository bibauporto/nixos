
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
    memoryPercent = 70; # Provides ~11.2GB of compressed swap space.
    priority = 100;      # Higher priority than disk swap.
  };

  # Physical Swap (Last resort/Safety net)
  swapDevices = [{ 
    device = "/persist/swap/swapfile"; 
    priority = 0; 
  }];

  # Performance Tuning for Web Dev (Docker/VSCode)
  boot.kernel.sysctl = {
    # Delay swapping until roughly 12GB of RAM is in use.
    "vm.swappiness" = 10;

    # Don't evict the filesystem cache too aggressively (keeps VS Code snappy).
    "vm.vfs_cache_pressure" = 50;

    # Required for some Docker containers and VS Code's file watcher.
    "fs.inotify.max_user_watches" = 524288;
  };
}



    
  
  

