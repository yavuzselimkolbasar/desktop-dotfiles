{ config, pkgs, lib, hostConfig, ... }:

let
  isNvidia = hostConfig.gpu == "nvidia";
in
{
  # =========================================================
  # POWER PROFILES DAEMON
  # =========================================================
  services.power-profiles-daemon.enable = true;

  # =========================================================
  # NVIDIA
  # =========================================================
  systemd.services.nvidia-profile-sync = lib.mkIf isNvidia {
    description = "Sync NVIDIA powermizer with power-profiles-daemon";
    wantedBy    = [ "graphical.target" ];
    after       = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type    = "simple";
      Restart = "on-failure";
      User    = "root";
    };

    script = ''
      apply() {
        case "$1" in
          performance) MODE=1 ;;   # prefer max performance
          balanced)    MODE=0 ;;   # adaptive
          power-saver) MODE=2 ;;   # auto / low
          *)           MODE=0 ;;
        esac
        echo "Setting NVIDIA powermizer mode: $MODE (profile: $1)"
        ${pkgs.glib}/bin/gdbus call \
          --system \
          --dest net.hadess.PowerProfiles \
          --object-path /net/hadess/PowerProfiles \
          --method org.freedesktop.DBus.Properties.Get \
          net.hadess.PowerProfiles ActiveProfile > /dev/null 2>&1 || true
        echo $MODE > /sys/bus/pci/devices/0000:01:00.0/power/control 2>/dev/null || true
      }

      # Apply current profile on service start
      CURRENT=$(${pkgs.glib}/bin/gdbus call \
        --system \
        --dest net.hadess.PowerProfiles \
        --object-path /net/hadess/PowerProfiles \
        --method org.freedesktop.DBus.Properties.Get \
          net.hadess.PowerProfiles ActiveProfile 2>/dev/null \
        | grep -oP "(?<=')[^']+(?=')" || echo "balanced")
      apply "$CURRENT"

      # Watch DBus for profile changes and apply immediately
      ${pkgs.glib}/bin/gdbus monitor \
        --system \
        --dest net.hadess.PowerProfiles \
        --object-path /net/hadess/PowerProfiles \
      | while IFS= read -r line; do
          PROFILE=$(echo "$line" \
            | grep -oP "'ActiveProfile'.*?'\K[^']+(?=')" || true)
          [[ -n "$PROFILE" ]] && apply "$PROFILE"
        done
    '';
  };

  # =========================================================
  # GAMEMODE
  # =========================================================
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice              = 10;
        ioprio              = 0;
        inhibit_screensaver = 1;
        softrealtime        = "auto";
      };
    };
  };

  services.irqbalance.enable = true;

  # =========================================================
  # SYSCTL
  # =========================================================
  boot.kernel.sysctl = {
    "fs.pipe-max-size"      = 8388608;
    "net.core.rmem_max"     = 16777216;
    "net.core.wmem_max"     = 16777216;
    "net.ipv4.tcp_fastopen" = 3;
  };
}
