{ pkgs, hostConfig, ... }:

{
  services.nextdns = {
    enable    = true;
    arguments = [
      "-profile"            hostConfig.nextdnsProfile
      "-cache-size"         "10MB"
      "-report-client-info"
    ];
  };

  systemd.services.nextdns-activate = {
    script   = "/run/current-system/sw/bin/nextdns activate";
    after    = [ "nextdns.service" ];
    wantedBy = [ "multi-user.target" ];
  };
}
