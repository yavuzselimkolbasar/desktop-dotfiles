{ config, pkgs, lib, ... }:

{
  system.autoUpgrade = {
    enable      = true;
    flake       = "/etc/nixos";
    dates       = "Sun 04:10";
    allowReboot = true;
  };

  systemd.services."nixos-upgrade-pre" = {
    before  = [ "nixos-upgrade.service" ];
    after   = [ "network-online.target" ];
    wants   = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      cd /etc/nixos
      ${pkgs.nix}/bin/nix flake update
    '';
  };

  systemd.services."nixos-upgrade" = {
    after = [ "nixos-upgrade-pre.service" ];
    wants = [ "nixos-upgrade-pre.service" ];
    postStart = lib.mkAfter ''
      ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 3d
      /run/current-system/sw/bin/shutdown -h +1 "Auto-upgrade done"
    '';
  };

  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 3d";
  };

  systemd.services."clean-temp" = {
    serviceConfig.Type = "oneshot";
    script = ''
      find /tmp     -mindepth 1 -mtime +7 -delete 2>/dev/null || true
      find /var/tmp -mindepth 1 -mtime +7 -delete 2>/dev/null || true
      for TRASH in /home/*/.local/share/Trash; do
        rm -rf "$TRASH/files/"* "$TRASH/info/"* 2>/dev/null || true
      done
    '';
  };

  systemd.timers."clean-temp" = {
    wantedBy    = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
