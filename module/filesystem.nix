{
  ...
}:

{
  ##############################
  # Root (impermanent)
  ##############################
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "size=2G"
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
  # Memory & Swap Optimizations
  ##############################

  zramSwap = {
    enable = true;
    memoryPercent = 40;
    priority = 100;
  };

  swapDevices = [
    {
      device = "/persist/swap/swapfile";
      priority = 0;
    }
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 150;
    "vm.page-cluster" = 0;

    "vm.vfs_cache_pressure" = 50;
    "fs.inotify.max_user_watches" = 524288;

    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
  };

}
