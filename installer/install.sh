#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════════════════════
# NixOS Installer
# Prompts for machine details → partitions → formats → writes host.nix →
# runs nixos-install → sets password → done.
# ══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
BOLD='\033[1m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'
RED='\033[1;31m'; CYAN='\033[1;36m'; NC='\033[0m'

header()  { echo -e "\n${CYAN}${BOLD}══ $* ══${NC}\n"; }
info()    { echo -e "  ${GREEN}✔${NC}  $*"; }
warn()    { echo -e "  ${YELLOW}⚠${NC}  $*"; }
die()     { echo -e "\n  ${RED}✘  Error: $*${NC}\n" >&2; exit 1; }
ask()     { echo -en "  ${BOLD}$*${NC} "; }

[[ $EUID -ne 0 ]] && die "Run as root (you should already be root on the ISO)"

# ── Welcome ───────────────────────────────────────────────────────────────────
clear
echo -e "${CYAN}${BOLD}"
cat <<'EOF'
  ███╗   ██╗██╗██╗  ██╗ ██████╗ ███████╗
  ████╗  ██║██║╚██╗██╔╝██╔═══██╗██╔════╝
  ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║███████╗
  ██║╚██╗██║██║ ██╔██╗ ██║   ██║╚════██║
  ██║ ╚████║██║██╔╝ ██╗╚██████╔╝███████║
  ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝
         Guided Installer
EOF
echo -e "${NC}"
echo -e "  This will partition your disk, install NixOS, and"
echo -e "  configure your personal environment automatically.\n"
read -rp "  Press Enter to begin, or Ctrl+C to cancel..."

# ══════════════════════════════════════════════════════════════════════════════
# 1. COLLECT USER INPUT
# ══════════════════════════════════════════════════════════════════════════════
header "System Identity"

ask "Hostname [Nixos-PC]:"; read -r HOSTNAME;   HOSTNAME=${HOSTNAME:-Nixos-PC}
ask "Username:";             read -r USERNAME;   [[ -z "$USERNAME" ]] && die "Username is required"
ask "Full name:";            read -r FULLNAME;   [[ -z "$FULLNAME" ]] && die "Full name is required"

echo ""
ask "Password:";         read -rsp "" PASSWORD;  echo ""
ask "Confirm password:"; read -rsp "" PASSWORD2; echo ""
[[ "$PASSWORD" != "$PASSWORD2" ]] && die "Passwords do not match"
[[ -z "$PASSWORD" ]]              && die "Password cannot be empty"

header "Locale & DNS"

ask "Timezone [Europe/Berlin]:"; read -r TIMEZONE; TIMEZONE=${TIMEZONE:-Europe/Berlin}
ask "Locale [en_US.UTF-8]:";     read -r LOCALE;   LOCALE=${LOCALE:-en_US.UTF-8}
echo ""
warn "NextDNS profile ID — find it at nextdns.io/setup (leave blank to disable)"
ask "NextDNS profile ID:"; read -r NEXTDNS_PROFILE

header "Hardware"

ask "CPU type — intel or amd [intel]:"; read -r CPU; CPU=${CPU:-intel}
[[ "$CPU" != "intel" && "$CPU" != "amd" ]] && die "CPU must be 'intel' or 'amd'"

ask "GPU type — nvidia, amd, or intel [nvidia]:"; read -r GPU; GPU=${GPU:-nvidia}
[[ "$GPU" != "nvidia" && "$GPU" != "amd" && "$GPU" != "intel" ]] && die "GPU must be 'nvidia', 'amd', or 'intel'"

header "Dual Boot"

echo ""
ask "Dual boot with Windows? (y/N):"; read -r _DB
DUALBOOT=false; [[ "${_DB,,}" == "y" ]] && DUALBOOT=true

# ══════════════════════════════════════════════════════════════════════════════
# 2. DISK SELECTION
# ══════════════════════════════════════════════════════════════════════════════
header "Disk Selection"

echo -e "  Available disks:\n"
lsblk -dpno NAME,SIZE,MODEL | grep -E "^/dev/(nvme|sd|vd)" | sed 's/^/    /'
echo ""
warn "The selected disk will be completely wiped."
ask "Install target (e.g. /dev/nvme0n1):"; read -r DISK
[[ ! -b "$DISK" ]] && die "Not a block device: $DISK"

echo ""
echo -e "  ${RED}${BOLD}ALL DATA ON ${DISK} WILL BE DESTROYED.${NC}"
ask "Type YES in capitals to confirm:"; read -r CONFIRM
[[ "$CONFIRM" != "YES" ]] && die "Aborted by user"

# ══════════════════════════════════════════════════════════════════════════════
# 3. OPTIONAL WINDOWS DISK
# ══════════════════════════════════════════════════════════════════════════════
NTFS_UUID_NIX="null"
NTFS_LABEL=""

if [[ "$DUALBOOT" == "true" ]]; then
  header "Windows Disk (optional)"
  echo -e "  NTFS partitions found:\n"
  lsblk -pno NAME,SIZE,FSTYPE,LABEL | grep -i ntfs | sed 's/^/    /' || echo "    (none detected)"
  echo ""
  ask "Windows partition to auto-mount (e.g. /dev/nvme1n1p3, blank to skip):"; read -r NTFS_PART
  if [[ -n "$NTFS_PART" ]]; then
    [[ ! -b "$NTFS_PART" ]] && die "Not a block device: $NTFS_PART"
    _UUID=$(blkid -s UUID -o value "$NTFS_PART")
    NTFS_UUID_NIX="\"${_UUID}\""
    ask "Mount label [Disk 2 | 512 GB]:"; read -r _LABEL
    NTFS_LABEL=${_LABEL:-"Disk 2 | 512 GB"}
    info "Will mount $NTFS_PART at /disks/${NTFS_LABEL}"
  fi
fi

# ══════════════════════════════════════════════════════════════════════════════
# 4. SUMMARY — last chance to bail
# ══════════════════════════════════════════════════════════════════════════════
header "Installation Summary"
echo -e "  Hostname   : ${BOLD}${HOSTNAME}${NC}"
echo -e "  Username   : ${BOLD}${USERNAME}${NC} (${FULLNAME})"
echo -e "  Timezone   : ${BOLD}${TIMEZONE}${NC}"
echo -e "  CPU / GPU  : ${BOLD}${CPU} / ${GPU}${NC}"
echo -e "  Dual boot  : ${BOLD}${DUALBOOT}${NC}"
echo -e "  Target disk: ${BOLD}${DISK}${NC}  ← will be wiped"
echo ""
ask "Proceed? (y/N):"; read -r GO
[[ "${GO,,}" != "y" ]] && die "Aborted by user"

# ══════════════════════════════════════════════════════════════════════════════
# 5. PARTITION
# ══════════════════════════════════════════════════════════════════════════════
header "Partitioning"

if [[ "$DISK" == *nvme* ]]; then
  EFI_PART="${DISK}p1"
  ROOT_PART="${DISK}p2"
else
  EFI_PART="${DISK}1"
  ROOT_PART="${DISK}2"
fi

info "Wiping partition table on ${DISK}"
sgdisk --zap-all "$DISK"

info "Creating EFI partition  (1 GiB)"
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:EFI "$DISK"

info "Creating root partition (rest of disk)"
sgdisk -n 2:0:0   -t 2:8300 -c 2:root "$DISK"

partprobe "$DISK"
sleep 1

# ══════════════════════════════════════════════════════════════════════════════
# 6. FORMAT
# ══════════════════════════════════════════════════════════════════════════════
header "Formatting"
info "Formatting EFI  → FAT32"
mkfs.fat -F32 -n EFI "$EFI_PART"

info "Formatting root → BTRFS"
mkfs.btrfs -f -L nixos "$ROOT_PART"

# ══════════════════════════════════════════════════════════════════════════════
# 7. BTRFS SUBVOLUMES
# ══════════════════════════════════════════════════════════════════════════════
header "BTRFS Subvolumes"
mount "$ROOT_PART" /mnt

info "Creating @"
btrfs subvolume create /mnt/@

info "Creating @home"
btrfs subvolume create /mnt/@home

umount /mnt

# ══════════════════════════════════════════════════════════════════════════════
# 8. MOUNT
# ══════════════════════════════════════════════════════════════════════════════
header "Mounting"
BTRFS_OPTS="compress=zstd,noatime"

mount -o "subvol=@,${BTRFS_OPTS}"     "$ROOT_PART" /mnt
mkdir -p /mnt/{home,boot}
mount -o "subvol=@home,${BTRFS_OPTS}" "$ROOT_PART" /mnt/home
mount "$EFI_PART" /mnt/boot

info "Mounted /mnt"

# ══════════════════════════════════════════════════════════════════════════════
# 9. COLLECT UUIDs
# ══════════════════════════════════════════════════════════════════════════════
ROOT_UUID=$(blkid -s UUID -o value "$ROOT_PART")
BOOT_UUID=$(blkid -s UUID -o value "$EFI_PART")
info "Root UUID : ${ROOT_UUID}"
info "Boot UUID : ${BOOT_UUID}"

# ══════════════════════════════════════════════════════════════════════════════
# 10. COPY CONFIG + WRITE host.nix
# ══════════════════════════════════════════════════════════════════════════════
header "Writing Configuration"

mkdir -p /mnt/etc/nixos

info "Copying config from ISO"
cp -r /iso/nixos-config/. /mnt/etc/nixos/

info "Writing host.nix"
cat > /mnt/etc/nixos/host.nix <<HOSTNIX
# Generated by installer on $(date '+%Y-%m-%d')
# Edit this file and run: nixos-rebuild switch --flake /etc/nixos#${HOSTNAME}
{
  username       = "${USERNAME}";
  fullName       = "${FULLNAME}";
  hostname       = "${HOSTNAME}";
  timezone       = "${TIMEZONE}";
  locale         = "${LOCALE}";
  nextdnsProfile = "${NEXTDNS_PROFILE}";

  cpu            = "${CPU}";
  gpu            = "${GPU}";

  dualBoot       = ${DUALBOOT};

  rootUuid       = "${ROOT_UUID}";
  bootUuid       = "${BOOT_UUID}";
  ntfsUuid       = ${NTFS_UUID_NIX};
  ntfsLabel      = "${NTFS_LABEL}";
}
HOSTNIX

info "host.nix written"

# ══════════════════════════════════════════════════════════════════════════════
# 11. INSTALL
# ══════════════════════════════════════════════════════════════════════════════
header "Installing NixOS"
warn "This will take a while — packages are being fetched and built."
echo ""

nixos-install \
  --flake "/mnt/etc/nixos#${HOSTNAME}" \
  --no-root-passwd \
  --root /mnt

# ══════════════════════════════════════════════════════════════════════════════
# 12. SET USER PASSWORD
# ══════════════════════════════════════════════════════════════════════════════
header "Setting Password for '${USERNAME}'"
nixos-enter --root /mnt -- passwd "${USERNAME}" <<PASSWD
${PASSWORD}
${PASSWORD}
PASSWD
info "Password set"

# ══════════════════════════════════════════════════════════════════════════════
# 13. DONE
# ══════════════════════════════════════════════════════════════════════════════
header "Installation Complete"
echo -e "  ${GREEN}${BOLD}NixOS has been installed successfully.${NC}"
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo -e "  1. Remove the USB drive"
echo -e "  2. Reboot into your new system"
echo -e "  3. For Secure Boot: run  ${CYAN}sudo sbctl create-keys${NC}"
echo -e "                      then ${CYAN}sudo sbctl enroll-keys --microsoft${NC}"
echo -e "                      then enable Secure Boot in your UEFI firmware"
echo -e "  4. Your config lives at  ${CYAN}/etc/nixos/${NC} — edit host.nix for any changes"
echo ""
ask "Reboot now? (Y/n):"; read -r RB
[[ "${RB,,}" != "n" ]] && reboot
