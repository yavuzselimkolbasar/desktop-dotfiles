{ config, pkgs, lib, hostConfig, ... }:

{
  # ==================================================
  # NETWORKING
  # ==================================================
  networking = {
    hostName              = hostConfig.hostname;
    networkmanager.enable = true;
  };

  # ==================================================
  # TIME & LOCALE
  # ==================================================
  time.timeZone = hostConfig.timezone;

  i18n = {
    defaultLocale       = hostConfig.locale;
    extraLocaleSettings = {
      LC_ADDRESS        = hostConfig.locale;
      LC_IDENTIFICATION = hostConfig.locale;
      LC_MEASUREMENT    = "en_GB.UTF-8";
      LC_MONETARY       = hostConfig.locale;
      LC_NAME           = hostConfig.locale;
      LC_NUMERIC        = hostConfig.locale;
      LC_PAPER          = hostConfig.locale;
      LC_TELEPHONE      = hostConfig.locale;
      LC_TIME           = "en_GB.UTF-8";
    };
  };

  # ==================================================
  # KEYBOARD
  # ==================================================
  services.xserver.xkb = {
    layout  = "us";
    variant = "";
  };

  # ==================================================
  # USER
  # ==================================================
  users.users.${hostConfig.username} = {
    isNormalUser = true;
    description  = hostConfig.fullName;
    extraGroups  = [ "audio" "gamemode" "networkmanager" "wheel" ];
    packages     = with pkgs; [ flatpak sbctl ];
  };

  # ==================================================
  # INPUT DEVICES
  # ==================================================
  services.libinput = {
    enable                  = true;
    mouse.scrollMethod      = "button";
    mouse.scrollButton      = 274;
    mouse.additionalOptions = ''Option "ScrollButtonLock" "true"'';
  };

  # ==================================================
  # NIX
  # ==================================================
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store   = true;
  };

  # ==================================================
  # STATE VERSION
  # ==================================================
  system.stateVersion = "25.11";
}
