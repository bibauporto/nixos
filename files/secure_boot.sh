#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "This program must be run as root (sudo)."
  exit 1
fi

# Detect original user (SUDO_USER)
REAL_USER="$SUDO_USER"
if [ -z "$REAL_USER" ]; then
  echo "Error: Could not detect the original user (SUDO_USER is empty)."
  exit 1
fi

run_as_user() {
  sudo -u "$REAL_USER" "$@"
}

echo ""
echo "--- Secure Boot Setup (sbctl) ---"

echo "Creating keys..."
sbctl create-keys

echo "Enrolling keys (Microsoft friendly)..."
sbctl enroll-keys -m

echo "Signing boot files..."

if command -v sbctl-batch-sign &>/dev/null; then
  echo "Using sbctl-batch-sign to sign all detected files..."
  sbctl-batch-sign
else
  echo "sbctl-batch-sign not found, falling back to manual signing..."

  for k in /boot/vmlinuz-*; do
    [ -e "$k" ] || continue
    echo "Signing kernel: $k"
    sbctl sign -s "$k"
  done

  find /boot -name "linux" -type f | while read -r path; do
    echo "Signing systemd-boot kernel: $path"
    sbctl sign -s "$path"
  done

  EFI_FILES=(
    "/boot/EFI/BOOT/BOOTX64.EFI"
    "/boot/EFI/systemd/systemd-bootx64.efi"
    "/usr/lib/systemd/boot/efi/systemd-bootx64.efi"
  )

  for f in "${EFI_FILES[@]}"; do
    if [ -f "$f" ]; then
      echo "Signing EFI file: $f"
      sbctl sign -s "$f"
    fi
  done
fi

echo ""
echo "Secure Boot setup finished. Check 'sbctl status' and 'sbctl verify'."
