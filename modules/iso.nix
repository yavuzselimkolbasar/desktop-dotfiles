{ config, pkgs, lib, modulesPath, hostConfig, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/iso-image.nix")
  ];

  # ── ISO image settings ────────────────────────────────────────────────────
  isoImage.squashfsCompression = "zstd -Xcompression-level 6";
  isoImage.makeEfiBootable     = true;
  isoImage.makeUsbBootable     = true;
  image.fileName = "nixos-installer.iso"; 
  isoImage.contents = [{
    source = ../.;
    target = "/nixos-config";
  }];

  # ── Boot ─────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = lib.mkForce true;
  boot.loader.timeout = lib.mkForce 3;
  boot.kernelPatches = lib.mkForce [];
  boot.kernelPackages             = lib.mkForce pkgs.linuxPackages_latest;

  # ── Networking ───────────────────────────────────────────────────────────
  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkForce false;
  # ── Autologin as root ────────────────────────────────────────────────────
  services.getty.autologinUser = "root";
  users.users.root.initialPassword = "";

  # ── Installer tools ──────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    nixos-install-tools
    gptfdisk        # sgdisk
    btrfs-progs
    dosfstools      # mkfs.fat
    util-linux      # blkid, lsblk
    pciutils
    git
    curl
    wget
    parted
  ];

  # ── Install script ───────────────────────────────────────────────────────
  environment.etc."install".source = ../installer/install.sh;
  environment.etc."install".mode   = "0755";

  environment.shellInit = ''
    if [[ "$USER" == "root" && "$TERM" != "" ]]; then
      ln -sf /etc/install /usr/local/bin/install 2>/dev/null || true
    fi
  '';

  # Welcome banner shown on login
  environment.etc."issue".text = ''

    ┌─────────────────────────────────────────────────────┐
    │              NixOS Installer                        │
    │                                                     │
    │  Type  install  and press Enter to begin.           │
    │                                                     │
    │  You are logged in as root.                         │
    └─────────────────────────────────────────────────────┘

  '';

  # ── Nix settings on live media ────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}
