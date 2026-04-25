{
  flake.modules = {
    homeManager.mercury = {
      pkgs,
      config,
      username,
      inputs,
      ...
    }: let
      MATTERMOST_CLEANUP_RETENTION_WINDOW = "30 days";
    in {
      imports = [
        inputs.self.modules.homeManager.opencode
      ];

      programs.git.settings.user.email = "kyokley@mercury";

      home = {
        sessionVariables = {
          QTILE_NET_INTERFACE = "enp14s0";
        };

        packages = [
          pkgs.mattermost-desktop
        ];

        stateVersion = "24.05"; # Don't touch me!
      };

      systemd.user.services = {
        mattermost-clean-old-posts = {
          Unit.Description = "Remove old posts from mattermost";
          Service = {
            Type = "oneshot";
            ExecStart = toString (
              pkgs.writeShellScript "mattermost-clean-old-posts" ''
                cd /home/${username}/workspace/mattermost
                ${pkgs.docker}/bin/docker compose exec postgres17 psql -U mmuser -d mattermost -c "
                  begin;
                  delete from posts where createat < extract(epoch from (now() - interval '${MATTERMOST_CLEANUP_RETENTION_WINDOW}'))::int8 * 1000;
                  delete from reactions where postid not in (select id from posts);
                  delete from fileinfo where postid not in (select id from posts);
                  commit;
                  "
              ''
            );
          };
        };

        ollama-mattermost-bot = {
          Unit.Description = "Run Ollama Chatbot for Mattermost";
          Service = {
            ExecStart = toString (
              pkgs.writeShellScript "run-mattermost-bot" ''
                export BOT_TOKEN_PATH=${config.age.secrets.ollama-mattermost-bot-token.path}
                ${inputs.ollama-mattermost-bot.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/ollama-mattermost-bot
              ''
            );
            Environment = [
              "MATTERMOST_URL=mercury.taila5201.ts.net"
              "TEAM_NAME=Mercury"

              "OLLAMA_API_URL=http://100.92.134.123:11434"
              "OLLAMA_MODEL=llama3.2:3b"
            ];
          };
        };
      };

      systemd.user.timers = {
        mattermost-daily-task = {
          Unit = {
            Description = "Run tasks daily";
            After = ["network.target"];
          };
          Timer = {
            OnCalendar = "daily";
            RandomizedDelaySec = 14400;
            Persistent = true;
            Unit = "mattermost-clean-old-posts.service";
          };
          Install.WantedBy = ["timers.target"];
        };

        ollama-mattermost-bot-daily-task = {
          Unit = {
            Description = "Run tasks daily";
            After = ["network.target"];
          };
          Timer = {
            OnStartupSec = 300;
            Persistent = true;
            Unit = "ollama-mattermost-bot.service";
          };
          Install.WantedBy = ["timers.target"];
        };
      };
    };

    nixos.mercury = {
      inputs,
      pkgs,
      config,
      lib,
      modulesPath,
      ...
    }: {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.supportedFilesystems = ["bcachefs"];
      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.binfmt.emulatedSystems = [
        "aarch64-linux"
      ];

      system.stateVersion = "24.05"; # Don't touch me!

      programs.fuse = {
        userAllowOther = true;
      };

      # List packages installed in system profile. To search, run:
      # $ nix search wget
      environment.systemPackages = with pkgs; [
        ollama-rocm
        sshfs
      ];

      # Ollama server setup
      services.ollama = {
        enable = true;
        host = "100.92.134.123";
        loadModels = [
          "llama3.2:3b"
          "gpt-oss"
          "qwen3:8b"
          "qwen3-coder:30b"
          "gemma3:12b"
          "deepseek-r1:32b"
        ];
        environmentVariables = {
          # ROCR_VISIBLE_DEVICES = "1";
          HSA_OVERRIDE_GFX_VERSION = "11.0.2";
        };
        rocmOverrideGfx = "11.0.2";
      };

      networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.mkIf config.services.ollama.enable [
        11434
      ];
      boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod"];
      boot.initrd.kernelModules = ["amdgpu"];
      boot.kernelModules = ["kvm-amd" "amdgpu"];
      boot.extraModulePackages = [];

      fileSystems."/" = {
        device = "UUID=75f8e791-7457-4ae2-b6a1-dbcda9aed60b";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/764D-E9E8";
        fsType = "vfat";
        options = ["fmask=0777" "dmask=0777"];
      };

      swapDevices = [];

      # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
      # (the default) this is the recommended approach. When using systemd-networkd it's
      # still possible to use this option, but it's recommended to use it in conjunction
      # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
      networking.interfaces.enp14s0.useDHCP = lib.mkDefault true;
      # networking.interfaces.wlp15s0.useDHCP = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
  };
}
