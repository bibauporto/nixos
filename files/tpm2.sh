#!/bin/bash
set -e

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "This program must be run as root (sudo)."
  exit 1
fi

LUKS_DEVICE="/dev/nvme0n1p2"

# 1. Verification
if [ ! -b "$LUKS_DEVICE" ]; then
  echo "ERROR: Device $LUKS_DEVICE not found."
  exit 1
fi

# 2. Execution using nix-shell to ensure tools are present
nix-shell -p systemd cryptsetup --run "
    echo '--- TPM2 Syncing ---'
    
    # Wipe existing TPM2 metadata (Slot re-syncing)
    echo 'Wiping old TPM2 slots on $LUKS_DEVICE...'
    systemd-cryptenroll --wipe-slot=tpm2 '$LUKS_DEVICE'

    # Enroll with PCR 7 (Secure Boot Binding)
    echo 'Enrolling TPM2 with PCR 7...'
    systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 '$LUKS_DEVICE'

    echo '--- Recovery Key Check ---'
    
    # Check if a systemd-recovery token already exists in the LUKS metadata
    if cryptsetup luksDump '$LUKS_DEVICE' | grep -q 'systemd-recovery'; then
        echo 'Existing systemd recovery key found. Skipping generation to keep slots clean.'
    else
        echo 'No recovery key detected. Generating a new one...'
        echo '!!! SAVE THE RECOVERY KEY BELOW IN A SECURE PLACE !!!'
        systemd-cryptenroll --recovery-key '$LUKS_DEVICE'
    fi
"

echo ""
echo "✅ TPM2 enrollment complete for $LUKS_DEVICE."
