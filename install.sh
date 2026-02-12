#!/bin/bash
set -euo pipefail

########################################
# Disk and Hostname settings
########################################
export DISK="/dev/nvme0n1"
export HOSTNAME="lea"

# Flake source (mounted USB or external drive)
export FLAKE_SRC="/run/media/nixos/DISK"

########################################
# 1. Partition disk
########################################

echo "Partitioning disk $DISK..."
parted --script "$DISK" \
  mklabel gpt \
  mkpart ESP fat32 1MiB 2049MiB \
  set 1 esp on \
  mkpart primary 2049MiB 100%

echo "Formatting ESP partition as FAT32..."
mkfs.fat -F32 "${DISK}p1"

########################################
# 2. LUKS Encryption
########################################

echo "Setting up LUKS encryption on ${DISK}p2..."
cryptsetup luksFormat --type luks2 "${DISK}p2"
cryptsetup open "${DISK}p2" cryptroot

########################################
# 3. Create BTRFS filesystem and subvolumes
########################################

echo "Creating BTRFS filesystem..."
mkfs.btrfs -L nixos /dev/mapper/cryptroot

echo "Mounting encrypted partition (temporary)..."
mount /dev/mapper/cryptroot /mnt

echo "Creating BTRFS subvolumes..."
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/swap

umount /mnt

########################################
# 4. Mount layout (tmpfs root)
########################################

echo "Mounting tmpfs root..."
mount -t tmpfs -o size=8G,mode=755 tmpfs /mnt

echo "Creating mount directories..."
mkdir -p /mnt/{boot,nix,persist,swap,etc/nixos}

echo "Mounting ESP to /mnt/boot..."
mount "${DISK}p1" /mnt/boot

echo "Mounting BTRFS subvolumes..."
mount -o subvol=nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix
mount -o subvol=persist,compress=zstd,noatime /dev/mapper/cryptroot /mnt/persist
mount -o subvol=swap,noatime,nodatacow /dev/mapper/cryptroot /mnt/swap

########################################
# 5. Set up Swapfile
########################################

echo "Creating swapfile..."
truncate -s 0 /mnt/swap/swapfile
chattr +C /mnt/swap/swapfile
chmod 0600 /mnt/swap/swapfile
dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=16384 status=progress
mkswap /mnt/swap/swapfile
swapon /mnt/swap/swapfile

########################################
# 6. Copy Flake to /persist
########################################

echo "Copying flake configuration to /mnt/persist..."
mkdir -p /mnt/persist/etc/nixos
cp -rv "$FLAKE_SRC/nixos/"* /mnt/persist/etc/nixos/

########################################
# 7. Bind mount flake into tmpfs root
########################################

echo "Binding persistent nixos config into tmpfs root..."
mount --bind /mnt/persist/etc/nixos /mnt/etc/nixos

########################################
# 8. Generate hardware configuration
########################################

echo "Generating hardware configuration..."
nixos-generate-config --root /mnt

echo
echo "✅ Disk prepared. Ready for nixos-install."
echo "👉 Review /mnt/etc/nixos/hardware-configuration.nix before installing."

