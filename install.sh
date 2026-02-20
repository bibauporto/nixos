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
# Secure Boot (sbctl) Pre-check & Cleanup
########################################
echo "--- Cleaning up and checking Secure Boot status ---"

# Proactively remove existing temporary keys to prevent "old configuration" errors
rm -rf /etc/secureboot /var/lib/sbctl

# Resilient check for Setup Mode
if ! nix-shell -p sbctl --run "sbctl status" | grep "Setup Mode" | grep -qi "Enabled"; then
    echo "❌ Error: sbctl does not detect Setup Mode."
    nix-shell -p sbctl --run "sbctl status"
    exit 1
fi

########################################
# Disk and Hostname settings
########################################
export DISK="/dev/nvme0n1"
export HOSTNAME="lea"
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
mount -t tmpfs -o size=2G,mode=755 tmpfs /mnt

# Ensure all mount directories exist before mounting subvolumes
mkdir -p /mnt/{boot,nix,persist,etc/nixos,var/lib}

mount "${DISK}p1" /mnt/boot
mount -o subvol=nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix
mount -o subvol=persist,compress=zstd,noatime /dev/mapper/cryptroot /mnt/persist

########################################
# 5. Secure Boot Keys (Lanzaboote)
########################################
echo "--- Initializing Secure Boot Keys ---"

# Ensure clean directory exists on Live ISO before running sbctl
mkdir -p /etc/secureboot

# Generate and enroll keys
nix-shell -p sbctl --run "sbctl create-keys && sbctl enroll-keys -m"

# Copy to persistent storage
mkdir -p /mnt/persist/etc/secureboot
cp -rp /etc/secureboot/. /mnt/persist/etc/secureboot/

mkdir -p /mnt/persist/var/lib/sbctl
if [ -d "/var/lib/sbctl" ]; then
    cp -rp /var/lib/sbctl/. /mnt/persist/var/lib/sbctl/
fi

# Link to standard paths for the installer
ln -snf /persist/etc/secureboot /mnt/etc/secureboot
ln -snf /persist/var/lib/sbctl /mnt/var/lib/sbctl

########################################
# 6. Set up Swapfile (No-CoW)
########################################
echo "--- Creating 16GB Btrfs-safe swapfile ---"
mkdir -p /mnt/persist/swap
touch /mnt/persist/swap/swapfile
chattr +C /mnt/persist/swap/swapfile
fallocate -l 16G /mnt/persist/swap/swapfile
chmod 0600 /mnt/persist/swap/swapfile
mkswap /mnt/persist/swap/swapfile
swapon /mnt/persist/swap/swapfile

########################################
# 7. Write Hardware Configuration
########################################
echo "--- Writing hardware-configuration.nix ---"

# Explicitly create the path to avoid "No such file or directory" errors
mkdir -p /mnt/etc/nixos

cat <<EOF > /mnt/etc/nixos/hardware-configuration.nix
{ config, lib, pkgs, modulesPath, ... }: 
{ 
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ]; 

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ]; 
  boot.initrd.kernelModules = [ ]; 
  boot.kernelModules = [ "kvm-intel" ]; 
  boot.extraModulePackages = [ ]; 

  boot.initrd.luks.devices.cryptroot = { 
    device = "${DISK}p2"; 
    preLVM = true; 
  };

}
EOF

########################################
# 8. Copy Flake & Install
########################################
echo "--- Copying Flake configuration ---"
mkdir -p /mnt/persist/etc/nixos
if [ -d "$FLAKE_SRC" ]; then
    cp -rv "$FLAKE_SRC/nixos/"* /mnt/persist/etc/nixos/
fi

# Bind mount so installer sees the combined config (flake + hardware-config)
mount --bind /mnt/persist/etc/nixos /mnt/etc/nixos

echo "✅ System prepared. Checking internet for flake update..."
# Check for internet before trying to update, as seen in error
if ping -c 1 github.com &> /dev/null; then
    cd /mnt/etc/nixos && nix flake update --extra-experimental-features 'nix-command flakes'
else
    echo "⚠️ No internet detected. Flake update skipped. Proceeding with existing lockfile."
fi

echo "🚀 Ready to install."
read -p "Begin nixos-install? (y/N): " confirm
if [[ $confirm == [yY] ]]; then
    nixos-install --flake /mnt/etc/nixos#lea-pc
else
    echo "Aborted."
fi
