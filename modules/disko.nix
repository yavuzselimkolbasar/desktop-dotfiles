{ hostConfig, ... }:

{
  disko.devices = {
    disk.main = {
      device = hostConfig.disk;
      type   = "disk";

      content = {
        type = "gpt";

        partitions = {
          ESP = {
            size     = "1G";
            type     = "EF00";
            content  = {
              type   = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0077" "dmask=0077" ];
            };
          };

          root = {
            size    = "100%";
            content = {
              type   = "btrfs";
              extraArgs = [ "-f" "-L" "nixos" ];

              subvolumes = {
                "@" = {
                  mountpoint    = "/";
                  mountOptions  = [ "subvol=@" "compress=zstd" "noatime" "x-gvfs-show" ];
                };
                "@home" = {
                  mountpoint    = "/home";
                  mountOptions  = [ "subvol=@home" "compress=zstd" "noatime" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
