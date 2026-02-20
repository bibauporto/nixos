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
# Secure Boot (sbctl) Pre-check
########################################
echo "--- Checking Secure Boot status ---"
# We use nix-shell to access sbctl without pre-installing it on the ISO
if ! nix-shell -p sbctl --run "sbctl status" | grep -q "Setup Mode:             Enabled"; then
    echo "❌ Error: System is not in Setup Mode."
    echo "Please enter BIOS and clear/reset Secure Boot keys to 'Setup Mode'."
    exit 1
fi

########################################
# Disk and Hostname settings
########################################
export DISK="/dev/nvme0n1"
export HOSTNAME="lea"
# Ensure this matches your actual USB/Source path
export FLAKE_SRC="/run/media/nixos/DISK"

########################################
# 1. Partition disk
########################################
echo "--- Partitioning disk $DISK ---"
wipefs -a "$DISK"
parted --script "$DISK" \
    mklabel gpt \
    mkpart ESP fat32 1MiB 2049MiB \
    set 1 esp on \
    mkpart primary 2049MiB 100%

echo "Formatting ESP partition..."
mkfs.fat -F32 -n boot "${DISK}p1"

########################################
# 2. LUKS Encryption
########################################
echo "--- Setting up LUKS encryption ---"
cryptsetup luksFormat --type luks2 "${DISK}p2"
cryptsetup open "${DISK}p2" cryptroot

########################################
# 3. Create BTRFS filesystem and subvolumes
########################################
echo "--- Creating BTRFS subvolumes ---"
mkfs.btrfs -L nixos -f /dev/mapper/cryptroot
mount -t btrfs /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
umount /mnt

########################################
# 4. Mount layout (tmpfs root)
########################################
echo "--- Setting up tmpfs root and mounts ---"
mount -t tmpfs -o size=8G,mode=755 tmpfs /mnt
mkdir -p /mnt/{boot,nix,persist,etc,var/lib}

mount "${DISK}p1" /mnt/boot
mount -o subvol=nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix
mount -o subvol=persist,compress=zstd,noatime /dev/mapper/cryptroot /mnt/persist

########################################
# 5. Secure Boot Keys (Lanzaboote)
########################################
echo "--- Initializing Secure Boot Keys ---"
# Create keys and enroll them with Microsoft's signatures (-m)
nix-shell -p sbctl --run "sbctl create-keys && sbctl enroll-keys -m"

# Move keys to /persist so Lanzaboote can find them after reboot
mkdir -p /mnt/persist/etc/secureboot
cp -r /etc/secureboot/* /mnt/persist/etc/secureboot/

# Move sbctl database to /persist/var/lib/sbctl
mkdir -p /mnt/persist/var/lib/sbctl
if [ -d "/var/lib/sbctl" ]; then
    cp -r /var/lib/sbctl/* /mnt/persist/var/lib/sbctl/
fi

# Create symlinks so the installer sees them at standard paths
ln -s /persist/etc/secureboot /mnt/etc/secureboot
ln -s /persist/var/lib/sbctl /mnt/var/lib/sbctl

########################################
# 6. Set up Swapfile (No-CoW)
########################################
echo "--- Creating 16GB Btrfs-safe swapfile ---"
mkdir -p /mnt/persist/swap
touch /mnt/persist/swap/swapfile
# Strip compression and apply No-Copy-on-Write
chattr +C /mnt/persist/swap/swapfile
fallocate -l 16G /mnt/persist/swap/swapfile
chmod 0600 /mnt/persist/swap/swapfile
mkswap /mnt/persist/swap/swapfile
swapon /mnt/persist/swap/swapfile

########################################
# 7. Copy Flake & Install
########################################
echo "--- Copying Flake configuration ---"
mkdir -p /mnt/persist/etc/nixos
if [ -d "$FLAKE_SRC" ]; then
    cp -rv "$FLAKE_SRC/nixos/"* /mnt/persist/etc/nixos/
fi

# Bind mount for the installer to find the flake at /etc/nixos
mount --bind /mnt/persist/etc/nixos /mnt/etc/nixos

echo "✅ Ready to install NixOS with Secure Boot (Lanzaboote)."
read -p "Begin installation? (y/N): " confirm
if [[ $confirm == [yY] ]]; then
    nixos-install --flake /mnt/etc/nixos#lea-pc
else
    echo "Aborted. Filesystem is still mounted at /mnt."
fi
