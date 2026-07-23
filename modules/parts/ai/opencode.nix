{
  flake.modules.homeManager = {
    opencode = {
      pkgs,
      inputs,
      config,
      lib,
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
      };

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

      oh_my_opencode_slim = {
        preset = "opencode-free";
        presets = {
          openai = mkPreset {
            orchestrator = {model = "opencode/gpt-5.5";};
            oracle = {
              model = "opencode/gpt-5.5";
              variant = "high";
            };
            librarian = {
              model = "opencode/gpt-5.4-mini";
              variant = "low";
            };
            explorer = {
              model = "opencode/gpt-5.4-mini";
              variant = "low";
            };
            designer = {model = "opencode/gpt-5.4-mini";};
            fixer = {
              model = "opencode/gpt-5.4-mini";
              variant = "low";
            };
            council = {model = "opencode/gpt-5.5";};
          };
          opencode-go = mkPreset {
            orchestrator = {model = "opencode/glm-5.1";};
            oracle = {
              model = "opencode/glm-5.1";
              variant = "max";
            };
            librarian = {model = "opencode/minimax-m2.7";};
            explorer = {model = "opencode/minimax-m2.7";};
            designer = {model = "opencode/kimi-k2.6";};
            fixer = {
              model = "opencode/deepseek-v4-flash";
              variant = "high";
            };
            council = {model = "opencode/glm-5.1";};
          };
          opencode-free = mkPreset {
            orchestrator = {model = "opencode/big-pickle";};
            oracle = {
              model = "opencode/big-pickle";
              variant = "max";
            };
            librarian = {model = "opencode/minimax-m2.7";};
            explorer = {model = "opencode/minimax-m2.7";};
            designer = {model = "opencode/kimi-k2.6";};
            fixer = {
              model = "opencode/deepseek-v4-flash";
              variant = "high";
            };
            council = {model = "opencode/big-pickle";};
          };
        };
      };
      zen_key_path = "${config.home.homeDirectory}/.config/opencode/zen.key";
    in {
      imports = [inputs.self.modules.homeManager.gitoc];
      programs = {
        opencode = {
          enable = true;
          commands = {
            commit = ./conventional-commit-with-gitmoji-ai-prompt.md;
            review = ./review_code.md;
          };
          agents = {
            code-reviewer = ''
              # Code Reviewer Agent

              You are a senior software engineer specializing in code reviews.
              Focus on code quality, security, and maintainability.

              ## Guidelines
              - Review for potential bugs and edge cases
              - Check for security vulnerabilities
              - Ensure code follows best practices
              - Suggest improvements for readability and performance
            '';
            documentation = ''
              # Documentation Agent

              You are an expert technical writer focused on creating clear and concise documentation.
              Your goal is to help developers understand how to use the code effectively.

              ## Guidelines
              - Create user-friendly documentation
              - Include examples and use cases
              - Explain complex concepts in simple terms
              - Ensure accuracy and completeness
            '';
            security-auditor = ''
              ---
              description: Reviews code for quality and best practices
              mode: primary
              temperature: 0.1
              permission:
                write: deny
                edit: deny
                bash: deny
              ---
              You are a cybersecurity expert specializing in code security audits.
              Your primary focus is identifying and mitigating security risks in codebases.

              ## Guidelines
              - Identify potential security vulnerabilities
              - Assess the impact and likelihood of each vulnerability
              - Provide actionable recommendations for mitigation
              - Stay up-to-date with the latest security threats and best practices
            '';
          };
          settings = {
            autoupdate = false;
            provider = {
              opencode = {
                options = {
                  apiKey = "{file:${zen_key_path}}";
                  baseUrl = "https://opencode.ai/zen/v1";
                };
              };
            };
            model = "opencode/big-pickle";
            small_model = "opencode/big-pickle";
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
          };
        };
      };

      age.secrets = {
        opencode-zen = {
          file = ../_secrets/opencode_zen.age;
          path = zen_key_path;
        };
      };

      home =
        if config.programs.opencode.enable
        then {
          file = {
            ".config/opencode/oh-my-opencode-slim.json" = {
              text = builtins.toJSON oh_my_opencode_slim;
            };
            ".config/opencode/node_modules" = {
              source = npm_deps;
              recursive = true;
            };
          };

          packages = with pkgs; [
            glow
            nixd
          ];

          shellAliases = {
            review = "opencode --command review run | if [ -t 1 ]; then glow --tui -; else cat; fi";
          };
        }
        else {};
    };
  };
}
