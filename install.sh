#!/bin/bash
set -euo pipefail

# Check for root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root."
    exit 1
fi

# Check for UEFI mode
if [ ! -d "/sys/firmware/efi/efivars" ]; then
    echo "Error: System is not booted in UEFI mode!"
    exit 1
fi

########################################
# Disk and Hostname settings
########################################
export DISK="/dev/nvme0n1"
export HOSTNAME="lea"

# Flake source (mounted USB or external drive)
# Ensure this matches where your flake is actually located
export FLAKE_SRC="/run/media/nixos/DISK"

########################################
# 1. Partition disk
########################################

echo "Partitioning disk $DISK..."
# Zap existing partitions to avoid conflicts
wipefs -a "$DISK"

parted --script "$DISK" \
    mklabel gpt \
    mkpart ESP fat32 1MiB 2049MiB \
    set 1 esp on \
    mkpart primary 2049MiB 100%

echo "Formatting ESP partition as FAT32..."
mkfs.fat -F32 -n boot "${DISK}p1"

########################################
# 2. LUKS Encryption
########################################

echo "Setting up LUKS encryption on ${DISK}p2..."
# This will prompt for your passphrase
cryptsetup luksFormat --type luks2 "${DISK}p2"
cryptsetup open "${DISK}p2" cryptroot

########################################
# 3. Create BTRFS filesystem and subvolumes
########################################

echo "Creating BTRFS filesystem..."
mkfs.btrfs -L nixos -f /dev/mapper/cryptroot

echo "Mounting encrypted partition (temporary)..."
mount -t btrfs /dev/mapper/cryptroot /mnt

echo "Creating BTRFS subvolumes..."
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist

umount /mnt

########################################
# 4. Mount layout (tmpfs root)
########################################

echo "Mounting tmpfs root..."
# 8GB is sufficient for root on a 16GB RAM system
mount -t tmpfs -o size=8G,mode=755 tmpfs /mnt

echo "Creating mount directories..."
mkdir -p /mnt/{boot,nix,persist,etc/nixos}

echo "Mounting ESP to /mnt/boot..."
mount "${DISK}p1" /mnt/boot

echo "Mounting BTRFS subvolumes..."
mount -o subvol=nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix
mount -o subvol=persist,compress=zstd,noatime /dev/mapper/cryptroot /mnt/persist

########################################
# 5. Set up Swapfile (Btrfs-safe Fixes)
########################################

echo "Creating Btrfs-optimized swapfile in /persist/swap..."
mkdir -p /mnt/persist/swap

# Ensure the file is clean
rm -f /mnt/persist/swap/swapfile
truncate -s 0 /mnt/persist/swap/swapfile

# Strip compression property to allow No-CoW
btrfs property set /mnt/persist/swap/swapfile compression ""

# Apply No-Copy-on-Write (+C)
chattr +C /mnt/persist/swap/swapfile

# Set permissions (Root only)
chmod 0600 /mnt/persist/swap/swapfile

# Allocate 16GB using fallocate (faster than dd)
echo "Allocating 16GB swap space..."
fallocate -l 16G /mnt/persist/swap/swapfile

# Format and activate immediately
mkswap /mnt/persist/swap/swapfile
swapon /mnt/persist/swap/swapfile

########################################
# 6. Copy Flake to /persist
########################################

echo "Copying flake configuration to /mnt/persist..."
mkdir -p /mnt/persist/etc/nixos
if [ -d "$FLAKE_SRC" ]; then
    cp -rv "$FLAKE_SRC/nixos/"* /mnt/persist/etc/nixos/
else
    echo "Warning: FLAKE_SRC ($FLAKE_SRC) not found."
    echo "Please copy your flake manually to /mnt/persist/etc/nixos before proceeding."
fi

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

echo "Cleaning generated config..."
# Removing redundant filesystem/swap definitions to prioritize your manual module
sed -i '/fileSystems\./d' /mnt/etc/nixos/hardware-configuration.nix
sed -i '/swapDevices/d' /mnt/etc/nixos/hardware-configuration.nix

echo
echo "✅ Disk prepared for LEA-PC."
echo "👉 Btrfs Swap: Enabled (No-CoW, 16GB)"
echo "👉 Impermanence: Ready (tmpfs root)"
echo

read -p "Ready to install? (y/N) " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    echo "Installing NixOS..."
    nixos-install --flake /mnt/persist/etc/nixos#lea-pc
else
    echo "Installation aborted. Filesystem remains mounted at /mnt."
fi