{
  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=6G"
        "mode=755"
        "relatime"
      ];
    };

    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";   # лучше заменить на by-id
      content = {
        type = "gpt";
        partitions = {
          # EFI
          ESP = {
            name = "ESP";
            size = "1G";                 # лучше 1G, чем 512M
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          # LUKS → Btrfs
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
              # FIDO2 + таймаут (оставь, если пользуешься ключом)
              settings.crypttabExtraOpts = [
                "fido2-device=auto"
                "token-timeout=10"
              ];
              content = {
                type = "btrfs";
                extraArgs = [ "-L" "nixos" "-f" ];
                subvolumes = {
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "subvol=nix"
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "subvol=persist"
                      "compress=zstd:3"
                      "noatime"
                      "ssd"
                      "discard=async"
                    ];
                  };
                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "32G";   # 32G достаточно при 27 ГБ RAM
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  # Важно — пути должны совпадать с mountpoint
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
}
