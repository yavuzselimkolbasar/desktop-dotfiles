{ config, pkgs, lib, hostConfig, ... }:

let
  isIntel  = hostConfig.cpu == "intel";
  isAmd    = hostConfig.cpu == "amd";
  isNvidia = hostConfig.gpu == "nvidia";
in
{
  # ===========================================================================
  # BINARY CACHE
  # ===========================================================================
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://xddxdd.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "xddxdd.cachix.org-1:ay1HJyNDYmlSwj5NXQG065C8LfoqqKaTNCyzeixGjf8="
    ];
  };

  # ===========================================================================
  # CACHYOS KERNEL
  # ===========================================================================
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  # ===========================================================================
  # KERNEL PARAMS
  # ===========================================================================
  boot.kernelParams = [
    "quiet"
    "loglevel=0"
    "systemd.show_status=false"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=0"
    "udev.log_priority=0"
    "vt.global_cursor_default=0"
    "acpi_osi=Linux"
    "snd_intel_dspcfg.dsp_driver=1"
  ] ++ lib.optionals isNvidia [ "nvidia-drm.modeset=1" ]
    ++ lib.optionals isIntel  [ "intel_pstate=active"  ];

  # ===========================================================================
  # KERNEL CONFIG STRIP
  # ===========================================================================
  boot.kernelPatches = [{
    name  = "hardware-strip";
    patch = null;
    structuredExtraConfig = with lib.kernel; {

      # ── CPU ───────────────────────────────────────────────────────────────
      MNATIVE_INTEL    = lib.mkForce (if isIntel then yes    else no    );
      X86_INTEL_PSTATE = lib.mkForce (if isIntel then yes    else no    );
      INTEL_IDLE       = lib.mkForce (if isIntel then yes    else no    );
      MICROCODE_INTEL  = lib.mkForce (if isIntel then yes    else no    );
      MICROCODE_AMD    = lib.mkForce (if isAmd   then yes    else no    );
      X86_AMD_PSTATE   = lib.mkForce (if isAmd   then yes    else no    );

      # ── KVM ───────────────────────────────────────────────────────────────
      KVM_INTEL        = lib.mkForce (if isIntel then module else no    );
      KVM_AMD          = lib.mkForce (if isAmd   then module else no    );

      # ── Storage ───────────────────────────────────────────────────────────
      VMD              = lib.mkForce module;
      BLK_DEV_NVME     = lib.mkForce yes;

      # ── Filesystems ───────────────────────────────────────────────────────
      BTRFS_FS         = lib.mkForce yes;
      VFAT_FS          = lib.mkForce yes;
      NTFS3_FS         = lib.mkForce yes;
      EXT4_FS          = lib.mkForce no;
      XFS_FS           = lib.mkForce no;
      F2FS_FS          = lib.mkForce no;
      REISERFS_FS      = lib.mkForce no;
      JFS_FS           = lib.mkForce no;

      # ── GPU ─────────
      DRM_NOUVEAU      = lib.mkForce no;
      DRM_I915         = lib.mkForce no;
      DRM_AMDGPU       = lib.mkForce no;
      DRM_RADEON       = lib.mkForce no;
      DRM_VIRTIO_GPU   = lib.mkForce no;
      DRM_AST          = lib.mkForce no;

      # ── Network ──────────────────────────────
      R8169            = lib.mkForce module;
      E1000E           = lib.mkForce no;
      IGB              = lib.mkForce no;
      IXGBE            = lib.mkForce no;
      I40E             = lib.mkForce no;
      ICE              = lib.mkForce no;
      CFG80211         = lib.mkForce no;
      MAC80211         = lib.mkForce no;

      # ── Audio ─────────────────────────────────────────────────────────────
      SND_HDA_CODEC_CONEXANT = lib.mkForce no;
      SND_HDA_CODEC_CIRRUS   = lib.mkForce no;
      SND_HDA_CODEC_VIA      = lib.mkForce no;
      SND_HDA_CODEC_SIGMATEL = lib.mkForce no;
      SND_HDA_CODEC_SI3054   = lib.mkForce no;
      SND_HDA_CODEC_CMEDIA   = lib.mkForce no;

      # ── Memory ────────────────────────────────────────────────────────────
      ZSWAP              = lib.mkForce no;

      # ── Security ──────────────────────────────────────────────────────────
      SECURITY_LANDLOCK  = lib.mkForce yes;
      KEXEC              = lib.mkForce no;
      HIBERNATION        = lib.mkForce no;

      # ── Debug bloat ───────────────────────────────────────────────────────
      DEBUG_INFO_NONE    = lib.mkForce yes;
      DEBUG_KERNEL       = lib.mkForce no;
      SLUB_DEBUG         = lib.mkForce no;
      KASAN              = lib.mkForce no;
      UBSAN              = lib.mkForce no;
    };
  }];

}
