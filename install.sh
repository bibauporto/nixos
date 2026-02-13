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
# Swap subvolume is not needed if we put swapfile in /persist/swap/swapfile
# btrfs subvolume create /mnt/swap

umount /mnt

########################################
# 4. Mount layout (tmpfs root)
########################################

echo "Mounting tmpfs root..."
mount -t tmpfs -o size=8G,mode=755 tmpfs /mnt

echo "Creating mount directories..."
mkdir -p /mnt/{boot,nix,persist,etc/nixos}

echo "Mounting ESP to /mnt/boot..."
mount "${DISK}p1" /mnt/boot

echo "Mounting BTRFS subvolumes..."
mount -o subvol=nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix
mount -o subvol=persist,compress=zstd,noatime /dev/mapper/cryptroot /mnt/persist

########################################
# 5. Set up Swapfile
########################################

echo "Creating swapfile in /persist/swap..."
mkdir -p /mnt/persist/swap
truncate -s 0 /mnt/persist/swap/swapfile
chattr +C /mnt/persist/swap/swapfile
chmod 0600 /mnt/persist/swap/swapfile
# 16GB Swap
dd if=/dev/zero of=/mnt/persist/swap/swapfile bs=1M count=16384 status=progress
mkswap /mnt/persist/swap/swapfile
swapon /mnt/persist/swap/swapfile

########################################
# 6. Copy Flake to /persist
########################################

echo "Copying flake configuration to /mnt/persist..."
mkdir -p /mnt/persist/etc/nixos
# Check if source exists before copying
if [ -d "$FLAKE_SRC" ]; then
    cp -rv "$FLAKE_SRC/nixos/"* /mnt/persist/etc/nixos/
else
    echo "Warning: FLAKE_SRC ($FLAKE_SRC) not found. Skipping copy."
    echo "You must manually copy your flake to /mnt/persist/etc/nixos before installing."
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

echo "Stripping filesystem definitions from hardware-configuration.nix..."
# We remove fileSystems and swapDevices because they are defined in module/filesystem.nix
sed -i '/fileSystems\./d' /mnt/etc/nixos/hardware-configuration.nix
sed -i '/swapDevices/d' /mnt/etc/nixos/hardware-configuration.nix
# Also remove the block braces if they become empty? 
# Usually nixos-generate-config produces:
# fileSystems."/" = ...;
# So deleting lines containing fileSystems. should be enough.
# But we must ensure valid nix syntax.
# A safer way is to trust the user's manual module/filesystem.nix and just overwrite 
# the generated one, but keeping the LUKS config is crucial.
# The `boot.initrd.luks` is NOT a filesystem option, so it stays.

echo
echo "✅ Disk prepared."
echo "👉 Review /mnt/etc/nixos/hardware-configuration.nix before installing."
echo "👉 Ensure your 'module/filesystem.nix' matches the current mounts."

read -p "Ready to install? (y/N) " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
	echo "Installing NixOS..."
	nixos-install --flake /mnt/persist/etc/nixos#lea-pc
else
	echo "Installation aborted."
fi
