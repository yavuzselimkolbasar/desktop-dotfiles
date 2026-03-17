{ config, lib, pkgs, modulesPath, hostConfig, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # =========================================================
  # BOOT
  # =========================================================
  boot = {
    consoleLogLevel                 = 0;
    kernelModules = lib.optionals (hostConfig.cpu == "intel") [ "kvm-intel" ]
                 ++ lib.optionals (hostConfig.cpu == "amd")   [ "kvm-amd"   ];
    extraModulePackages = [ ];
    initrd = {
      verbose        = false;
      systemd.enable = true;
      availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules  = lib.optionals (hostConfig.gpu == "nvidia") [
        "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"
      ];
    };
  };

  # =========================================================
  # SECURE BOOT
  # =========================================================
  boot.lanzaboote = {
    enable    = true;
    pkiBundle = "/var/lib/sbctl";
  };
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  # =========================================================
  # HIDDEN BOOT MENU
  # =========================================================
  systemd.services.hidden-boot-menu = {
    description = "Set systemd-boot menu to hidden mode";
    wantedBy    = [ "multi-user.target" ];
    after       = [ "local-fs.target" ];
    serviceConfig = {
      Type      = "oneshot";
      User      = "root";
      ExecStart = pkgs.writeShellScript "hidden-boot-menu" ''
        sed -i '/^timeout/d' /boot/loader/loader.conf
        echo "timeout menu-hidden" >> /boot/loader/loader.conf
        sed -i '/^timeout/d' /boot/loader/loader.conf
        echo "timeout 5" >> /boot/loader/loader.conf
        sed -i '/^timeout/d' /boot/loader/loader.conf
        echo "timeout menu-hidden" >> /boot/loader/loader.conf
      '';
    };
  };

  # =========================================================
  # FILESYSTEMS
  # =========================================================
  fileSystems = {
    "/" = {
      device  = "/dev/disk/by-uuid/${hostConfig.rootUuid}";
      fsType  = "btrfs";
      options = [ "subvol=@" "compress=zstd" "noatime" "x-gvfs-show" ];
    };
    "/home" = {
      device  = "/dev/disk/by-uuid/${hostConfig.rootUuid}";
      fsType  = "btrfs";
      options = [ "subvol=@home" "compress=zstd" "noatime" ];
    };
    "/boot" = {
      device  = "/dev/disk/by-uuid/${hostConfig.bootUuid}";
      fsType  = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  } // lib.optionalAttrs (hostConfig.ntfsUuid != null) {
    "/disks/${hostConfig.ntfsLabel}" = {
      device  = "/dev/disk/by-uuid/${hostConfig.ntfsUuid}";
      fsType  = "ntfs-3g";
      options = [ "defaults" "nofail" "x-gvfs-show" "uid=1000" "gid=100" "umask=022" ];
    };
  };

  # =========================================================
  # ZRAM
  # =========================================================
  zramSwap = {
    enable        = true;
    algorithm     = "zstd";
    memoryPercent = 25;
  };

  # =========================================================
  # NVIDIA
  # =========================================================
  hardware.graphics = {
    enable      = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = lib.mkIf (hostConfig.gpu == "nvidia") [ "nvidia" ];

  hardware.nvidia = lib.mkIf (hostConfig.gpu == "nvidia") {
    modesetting.enable          = true;
    powerManagement.enable      = false;
    powerManagement.finegrained = false;
    open                        = false;
    nvidiaSettings              = true;
    package                     = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # =========================================================
  # MOUSE
  # =========================================================
  services.upower.enable = true;

  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="373b", ATTRS{idProduct}=="11d9", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="373b", ATTRS{idProduct}=="1201", MODE="0666"
  '';

  # =========================================================
  # AUDIO
  # =========================================================
  services.pulseaudio.enable = false;
  security.rtkit.enable      = true;

  services.pipewire = {
    enable             = true;
    alsa.enable        = true;
    alsa.support32Bit  = true;
    pulse.enable       = true;
    wireplumber.enable = true;
  };

  environment.etc."wireplumber/wireplumber.conf.d/50-disable-outputs.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [ { device.name = "alsa_card.pci-0000_01_00.1" } ]
        actions = { update-props = { device.disabled = true } }
      }
      {
        matches = [ { device.name = "alsa_card.pci-0000_06_00.1" } ]
        actions = { update-props = { device.disabled = true } }
      }
      {
        matches = [ { device.name = "alsa_card.usb-HP__Inc_HyperX_Cloud_II_Wireless_0-00" } ]
        actions = {
          update-props = {
            device.profile       = "output:analog-stereo+input:mono-fallback"
            api.acp.auto-profile = false
            api.acp.hidden-ports = "iec958-stereo-output"
          }
        }
      }
      {
        matches = [ { device.name = "alsa_card.pci-0000_00_1f.3" } ]
        actions = {
          update-props = {
            device.profile       = "output:analog-stereo"
            api.acp.auto-profile = false
            api.acp.hidden-ports = "iec958-stereo-output"
          }
        }
      }
    ]
  '';

  # =========================================================
  # PLATFORM
  # =========================================================
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.cpu.intel.updateMicrocode = lib.mkIf (hostConfig.cpu == "intel")
    (lib.mkDefault config.hardware.enableRedistributableFirmware);

  hardware.cpu.amd.updateMicrocode = lib.mkIf (hostConfig.cpu == "amd")
    (lib.mkDefault config.hardware.enableRedistributableFirmware);
}
