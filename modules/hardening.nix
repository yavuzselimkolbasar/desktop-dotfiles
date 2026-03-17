{ ... }:

{
  # ===========================================================================
  # SYSCTL
  # ===========================================================================
  boot.kernel.sysctl = {
    "kernel.dmesg_restrict"                 = 1;
    "kernel.kptr_restrict"                  = 2;
    "kernel.perf_event_paranoid"            = 2;
    "kernel.unprivileged_bpf_disabled"      = 1;
    "net.core.bpf_jit_harden"              = 2;
    "kernel.sysrq"                          = 0;
    "kernel.randomize_va_space"             = 2;
    "kernel.yama.ptrace_scope"              = 1;
    "fs.protected_hardlinks"                = 1;
    "fs.protected_symlinks"                 = 1;
    "fs.protected_fifos"                    = 2;
    "fs.protected_regular"                  = 2;
    "net.ipv4.conf.all.accept_redirects"    = 0;
    "net.ipv4.conf.all.send_redirects"      = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.all.rp_filter"           = 1;
    "net.ipv4.conf.all.log_martians"        = 1;
    "net.ipv4.tcp_syncookies"               = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts"  = 1;
    "net.ipv6.conf.all.accept_redirects"    = 0;
    "net.core.default_qdisc"                = "fq";
    "net.ipv4.tcp_congestion_control"       = "bbr";
    "vm.swappiness"                         = 10;
    "vm.vfs_cache_pressure"                 = 50;
    "kernel.nmi_watchdog"                   = 0;
  };

  # ===========================================================================
  # SYSTEMD
  # ===========================================================================
  systemd.settings.Manager = {
    DefaultLimitNOFILE      = 1048576;
    DefaultTasksMax         = "50%";
    DefaultMemoryAccounting = true;
    DefaultCPUAccounting    = true;
    DefaultIOAccounting     = true;
  };

  systemd.services.nextdns.serviceConfig = {
    CapabilityBoundingSet   = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
    AmbientCapabilities     = [ "CAP_NET_ADMIN" "CAP_NET_BIND_SERVICE" "CAP_NET_RAW" ];
    NoNewPrivileges         = true;
    PrivateTmp              = true;
    ProtectSystem           = "strict";
    ProtectHome             = true;
    ProtectKernelTunables   = true;
    ProtectKernelModules    = true;
    ProtectKernelLogs       = true;
    ProtectControlGroups    = true;
    ProtectHostname         = true;
    RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK" ];
    RestrictNamespaces      = true;
    RestrictRealtime        = true;
    RestrictSUIDSGID        = true;
    LockPersonality         = true;
    MemoryDenyWriteExecute  = true;
    SystemCallArchitectures = "native";
    SystemCallFilter        = [ "@system-service" "~@privileged" "~@resources" ];
  };

  systemd.services.NetworkManager.serviceConfig = {
    NoNewPrivileges         = true;
    ProtectKernelLogs       = true;
    ProtectHostname         = true;
    RestrictSUIDSGID        = true;
    LockPersonality         = true;
    SystemCallArchitectures = "native";
    RestrictNamespaces      = true;
  };

  systemd.user.services.wireplumber.serviceConfig = {
    NoNewPrivileges         = true;
    ProtectKernelTunables   = false;
    ProtectKernelModules    = true;
    ProtectKernelLogs       = true;
    ProtectHostname         = true;
    RestrictAddressFamilies = [ "AF_UNIX" "AF_NETLINK" ];
    RestrictNamespaces      = true;
    RestrictRealtime        = false;
    LockPersonality         = true;
    RestrictSUIDSGID        = true;
    SystemCallArchitectures = "native";
  };

  systemd.user.services.pipewire.serviceConfig = {
    NoNewPrivileges         = true;
    ProtectKernelTunables   = false;
    ProtectKernelModules    = true;
    ProtectKernelLogs       = true;
    ProtectHostname         = true;
    RestrictAddressFamilies = [ "AF_UNIX" "AF_NETLINK" ];
    RestrictRealtime        = false;
    RestrictNamespaces      = true;
    LockPersonality         = true;
    RestrictSUIDSGID        = true;
    SystemCallArchitectures = "native";
  };
}
