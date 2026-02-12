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
    fsType = "vfat";
  };

  ##############################
  # Swap (btrfs-safe)
  ##############################

  swapDevices = [
    { device = "/persist/swap/swapfile"; }
  ];
}

