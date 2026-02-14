
#!/bin/bash
set -e

[[ $EUID -ne 0 ]] && echo "Run as root (sudo)." && exit 1

echo "=== TPM2 LUKS Enrollment (Stability Optimized) ==="

### 1. Get root mount source and clean subvolume suffix
ROOT_SRC=$(findmnt / -n -o SOURCE)
ROOT_SRC=${ROOT_SRC%%[*}   # strip [/subvol]

### 2. Ensure it's a mapper device
if [[ "$ROOT_SRC" != /dev/mapper/* ]]; then
  echo "ERROR: Root is not mounted from a LUKS mapper device."
  echo "Detected source: $ROOT_SRC"
  exit 1
fi

MAPPER_NAME=${ROOT_SRC#/dev/mapper/}

### 3. Resolve backing LUKS device
LUKS_DEVICE=$(cryptsetup status "$MAPPER_NAME" 2>/dev/null | awk '/device:/ {print $2}')

if [[ -z "$LUKS_DEVICE" ]]; then
  echo "ERROR: Could not resolve LUKS backing device."
  exit 1
fi

echo "Target LUKS device: $LUKS_DEVICE"

### 4. TPM2 presence check
systemd-cryptenroll --tpm2-device=list >/dev/null

read -rp "Enroll TPM2 on $LUKS_DEVICE? (This will ignore external drive changes) (y/N): " CONFIRM
[[ "${CONFIRM,,}" != "y" ]] && exit 1

### 5. TPM2 Sync (The PCR 1 fix)
# PCR 0: Firmware/BIOS code
# PCR 2: Hardware Option ROMs
# PCR 7: Secure Boot state
# We EXCLUDE PCR 1 to allow external SSDs without breaking the seal.
PCR_POLICY="0+2+7"

echo "Wiping old TPM2 slots and enrolling with PCRs: $PCR_POLICY..."
systemd-cryptenroll --wipe-slot=tpm2 "$LUKS_DEVICE"
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs="$PCR_POLICY" "$LUKS_DEVICE"

### 6. Recovery Key Management
# Check if a recovery key (password slot) already exists to avoid duplicates
# systemd-cryptenroll recovery keys are technically 'recovery' type in newer systemd, 
# but usually show as 'password' slots in LUKS.
EXISTING_RECOVERY=$(cryptsetup luksDump "$LUKS_DEVICE" | grep -c "token:.*systemd-recovery")

if [ "$EXISTING_RECOVERY" -eq 0 ]; then
    echo "No systemd recovery key detected. Generating one now..."
    echo "!!! SAVE THE RECOVERY KEY BELOW IN A SAFE PLACE !!!"
    systemd-cryptenroll --recovery-key "$LUKS_DEVICE"
else
    echo "Existing systemd recovery key found. Skipping generation to keep slots clean."
fi

echo "✅ TPM2 enrollment complete. Your external SSD should no longer trigger a lockout."

