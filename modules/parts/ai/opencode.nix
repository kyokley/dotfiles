{lib, ...}: {
  flake.modules.homeManager = let
    agentDefaults = {
      orchestrator = {
        skills = ["*"];
        mcps = ["*" "!context7"];
      };
      oracle = {
        skills = ["simplify"];
        mcps = [];
      };
      council = {
        variant = "high";
        skills = [];
        mcps = [];
      };
      librarian = {
        skills = [];
        mcps = ["websearch" "context7" "grep_app"];
      };
      explorer = {
        skills = [];
        mcps = [];
      };
      designer = {
        variant = "medium";
        skills = [];
        mcps = [];
      };
      fixer = {
        skills = [];
        mcps = [];
      };
    };
    mkPreset = presetConfigs: lib.mapAttrs (name: config: agentDefaults.${name} // config) presetConfigs;
    mkPresetOverride = {
      preset,
      disabled_mcps ? [],
    }: {
      home.file.".config/opencode/oh-my-opencode-slim.json" = lib.mkForce {
        text = builtins.toJSON (oh_my_opencode_slim
          // {
            inherit preset disabled_mcps;
          });
      };
    };

    oh_my_opencode_slim = {
      preset = "opencode-zen";
      presets = {
        openai = mkPreset {
          orchestrator = {
            model = "openai/gpt-5.6-terra";
            variant = "high";
          };
          oracle = {
            model = "openai/gpt-5.6-sol";
            variant = "high";
          };
          librarian = {
            model = "openai/gpt-5.6-luna";
            variant = "low";
          };
          explorer = {
            model = "openai/gpt-5.6-luna";
            variant = "low";
          };
          designer.model = "openai/gpt-5.6-luna";
          fixer = {
            model = "openai/gpt-5.6-luna";
            variant = "high";
          };
          council.model = "openai/gpt-5.6-terra";
        };
        opencode-zen = mkPreset {
          orchestrator = {
            model = "opencode/glm-5.2";
            variant = "max";
          };
          oracle = {
            model = "opencode/glm-5.2";
          };
          librarian = {
            model = "opencode/deepseek-v4-flash";
          };
          explorer = {
            model = "opencode/deepseek-v4-flash";
          };
          designer = {
            model = "opencode/glm-5.2";
          };
          fixer = {
            model = "opencode/deepseek-v4-pro";
          };
          council = {
            model = "opencode/glm-5.2";
          };
        };
        opencode-free = mkPreset {
          orchestrator = {model = "opencode/mimo-v2.5-free";};
          oracle = {
            model = "opencode/nemotron-3-ultra-free";
            variant = "max";
          };
          librarian = {model = "opencode/mimo-v2.5-free";};
          explorer = {model = "opencode/ling-3.0-flash-fin-free";};
          designer = {model = "opencode/muse-spark-1.2-contributor-free";};
          fixer = {
            model = "opencode/nemotron-3.5-lightning-free";
            variant = "high";
          };
          council = {model = "opencode/mimo-v2.5-free";};
        };
      };
    };
  in {
    opencode = {
      pkgs,
      inputs,
      config,
      ...
    }: let
      bun2nix-lib = inputs.bun2nix.packages.${pkgs.stdenv.hostPlatform.system}.default;
      npm_deps = bun2nix-lib.mkDerivation {
        packageJson = ./package.json;
        src = ./.;

        bunDeps = bun2nix-lib.fetchBunDeps {
          bunNix = ./_bun.nix;
        };

        module = "package.json";
        dontUseBunBuild = true;
        dontRunLifecycleScripts = true;
        installPhase = ''
          runHook preInstall
          cp -R node_modules "$out"
          runHook postInstall
        '';
      };

      opencode_notify = pkgs.fetchFromGitHub {
        owner = "kdcokenny";
        repo = "ocx";
        rev = "636dc2dbd10a780ef9f4b7a0bbf175aacd742e8c";
        hash = "sha256-e2GbBB0RG8AjEZPwDkP1z94+K+vZ9hx1gq9OpHKWlh0=";
      };

      opencode_notify_plugin = pkgs.runCommand "opencode-notify-plugin" {} ''
        mkdir -p "$out/plugins"
        cp -R ${opencode_notify}/workers/kdco-registry/files/plugins/. "$out/plugins"
        ln -s ${npm_deps} "$out/node_modules"
      '';

      zen_key_path = "${config.home.homeDirectory}/.config/opencode/zen.key";
    in {
      _module.args.opencode_npm_deps = npm_deps;

      imports = [inputs.self.modules.homeManager.gitoc];
      programs = {
        opencode = {
          enable = true;
          context = builtins.readFile "${inputs.caveman}/plugins/caveman/skills/caveman/SKILL.md";
          commands = {
            commit = ./conventional-commit-with-gitmoji-ai-prompt.md;
            review = ./review_code.md;
          };
          settings = {
            autoupdate = false;
            provider = {
              opencode = {
                options = {
                  apiKey = "{file:${zen_key_path}}";
                  baseUrl = "https://opencode.ai/zen/v1";
                  timeout = 600000;
                  headerTimeout = 600000;
                };
              };
              openai = {
                options = {
                  timeout = 600000;
                  headerTimeout = 600000;
                };
              };
            };
            model = "opencode/gpt-5.6-luna";
            small_model = "opencode/gpt-5-nano";
            agent = {
              explore.disable = true;
              general.disable = true;
            };
            plugin = [
              "oh-my-opencode-slim"
              "opencode-skill-creator"
            ];
            permission = {
              external_directory = {
                "/nix/store/**" = "allow";
                "/tmp/**" = "allow";
              };
            };
            lsp = true;
            mcp = {
              "mv-mcp" = {
                enabled = false;
                type = "remote";
                url = "http://127.0.0.1:8089/mcp";
              };
            };
          };
        };
      };

      age.secrets = {
        opencode-zen = {
          file = ../_secrets/opencode_zen.age;
          path = zen_key_path;
        };
      };

      home = {
        file = {
          ".config/opencode/oh-my-opencode-slim.json" = {
            text = builtins.toJSON oh_my_opencode_slim;
          };
          ".config/opencode/kdco-notify.json" = {
            text = builtins.toJSON {timeout = 15;};
          };
          ".config/opencode/node_modules" = {
            source = npm_deps;
            recursive = true;
          };
          ".config/opencode/plugins/notify.ts".source = "${opencode_notify_plugin}/plugins/notify.ts";
          ".config/opencode/plugins/notify" = {
            source = "${opencode_notify_plugin}/plugins/notify";
            recursive = true;
          };
          ".config/opencode/plugins/kdco-primitives" = {
            source = "${opencode_notify_plugin}/plugins/kdco-primitives";
            recursive = true;
          };
        };

        packages =
          (with pkgs; [
            glow
            nixd
          ])
          ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [pkgs.libnotify];

        shellAliases = {
          review = "opencode --command review run | if [ -t 1 ]; then glow --tui -; else cat; fi";
        };
      };
    };

    "yokley@mars" = mkPresetOverride {preset = "openai";};
    "yokley@dioxygen" = mkPresetOverride {preset = "openai";};
    "yokley@saturn" = mkPresetOverride {
      preset = "openai";
      disabled_mcps = [
        "websearch"
        "grep_app"
        "context7"
        "gh_grep"
      ];
    };
  };
}
