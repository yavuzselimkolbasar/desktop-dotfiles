{ config, pkgs, lib, hostConfig, ... }:

{
  # ==================================================
  # GNOME + GDM
  # ==================================================
  services.xserver.enable              = true;
  programs.dconf.enable                = true;
  services.displayManager.gdm.enable   = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.core-apps.enable      = false;
  services.flatpak.enable              = true;

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-user-docs
    yelp
  ];

  # ==================================================
  # PORTALS
  # ==================================================
  xdg.portal.extraPortals          = [ pkgs.xdg-desktop-portal-gnome ];
  xdg.portal.config.common.default = "gnome";

  environment.sessionVariables = {
    XDG_DATA_DIRS = [
      "/var/lib/flatpak/exports/share"
      "/home/${hostConfig.username}/.local/share/flatpak/exports/share"
      "/etc/profiles/per-user/${hostConfig.username}/share"
    ];
    NIXOS_OZONE_WL = "1";
  };

  # ==================================================
  # SYSTEM PACKAGES
  # ==================================================
  environment.systemPackages = with pkgs; [
    nextdns
    efibootmgr
    gamemode
    gamescope
    scx.full
    xwayland
  ] ++ lib.optionals hostConfig.dualBoot [
    (pkgs.writeShellScriptBin "winboot" ''
      #!/bin/sh
      BOOTNUM=$(efibootmgr | grep -i "Windows Boot Manager" | grep '\*' | grep -oP 'Boot\K[0-9]+')
      if [ -z "$BOOTNUM" ]; then
        echo "Error: Windows Boot Manager not found"
        exit 1
      fi
      pkexec sh -c "efibootmgr -n '$BOOTNUM' > /dev/null 2>&1 || { echo 'Error: efibootmgr failed'; exit 1; } && reboot"
    '')
  ];

  # ==================================================
  # SCX SCHEDULER
  # ==================================================
  systemd.services.scx = {
    enable    = true;
    wantedBy  = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.scx.full}/bin/scx_lavd --autopower";
      Restart   = "on-failure";
    };
  };
}
