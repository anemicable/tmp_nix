{
  disko.devices = {
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "size=6GB"
          "mode=755"
        ];
    };

    };
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };

            esp = {
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };

            luks = {
              size = "100%";
              label = "luks";
              content = {
                type = "luks";
                name = "cryptroot";
                extraOpenArgs = [
                  "--allow-discards"
                  "--perf-no_read_workqueue"
                  "--perf-no_write_workqueue"
                ];
                settings = {crypttabExtraOpts = ["fido2-device=auto" "token-timeout=10"];};
                content = {
                  type = "btrfs";
                  extraArgs = ["-L" "nixos" "-f"];
                  subvolumes = {
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["subvol=nix" "compress=zstd" "noatime"];
                    };
                    "/persistent" = {
                      mountpoint = "/persist";
                      mountOptions = ["subvol=persist" "compress=zstd" "noatime"];
                    };
                    "/swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "64G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/nix".neededForBoot = true;
  fileSystems."/persistent".neededForBoot = true;
}
