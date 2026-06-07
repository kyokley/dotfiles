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
        # pname = "opencode deps";
        # version = "1.0.0";

        packageJson = ./package.json;
        src = ./.;

        bunDeps = bun2nix-lib.fetchBunDeps {
          bunNix = ./_bun.nix;
        };

        module = "package.json";
      };

      oh_my_opencode_slim = {
        preset = "opencode-free";
        presets = {
          openai = {
            orchestrator = {
              model = "opencode/gpt-5.5";
              skills = [
                "*"
              ];
              mcps = [
                "*"
                "!context7"
              ];
            };
            oracle = {
              model = "opencode/gpt-5.5";
              variant = "high";
              skills = [
                "simplify"
              ];
              mcps = [];
            };
            librarian = {
              model = "opencode/gpt-5.4-mini";
              variant = "low";
              skills = [];
              mcps = [
                "websearch"
                "context7"
                "grep_app"
              ];
            };
            explorer = {
              model = "opencode/gpt-5.4-mini";
              variant = "low";
              skills = [];
              mcps = [];
            };
            designer = {
              model = "opencode/gpt-5.4-mini";
              variant = "medium";
              skills = [];
              mcps = [];
            };
            fixer = {
              model = "opencode/gpt-5.4-mini";
              variant = "low";
              skills = [];
              mcps = [];
            };
            council = {
              model = "opencode/gpt-5.5";
              variant = "high";
              skills = [];
              mcps = [];
            };
          };
          opencode-go = {
            orchestrator = {
              model = "opencode/glm-5.1";
              skills = [
                "*"
              ];
              mcps = [
                "*"
                "!context7"
              ];
            };
            oracle = {
              model = "opencode/glm-5.1";
              variant = "max";
              skills = [
                "simplify"
              ];
              mcps = [];
            };
            council = {
              model = "opencode/glm-5.1";
              variant = "high";
              skills = [];
              mcps = [];
            };
            librarian = {
              model = "opencode/minimax-m2.7";
              skills = [];
              mcps = [
                "websearch"
                "context7"
                "grep_app"
              ];
            };
            explorer = {
              model = "opencode/minimax-m2.7";
              skills = [];
              mcps = [];
            };
            designer = {
              model = "opencode/kimi-k2.6";
              variant = "medium";
              skills = [];
              mcps = [];
            };
            fixer = {
              model = "opencode/deepseek-v4-flash";
              variant = "high";
              skills = [];
              mcps = [];
            };
          };
          opencode-free = {
            orchestrator = {
              model = "opencode/big-pickle";
              skills = [
                "*"
              ];
              mcps = [
                "*"
                "!context7"
              ];
            };
            oracle = {
              model = "opencode/big-pickle";
              variant = "max";
              skills = [
                "simplify"
              ];
              mcps = [];
            };
            council = {
              model = "opencode/big-pickle";
              variant = "high";
              skills = [];
              mcps = [];
            };
            librarian = {
              model = "opencode/minimax-m2.7";
              skills = [];
              mcps = [
                "websearch"
                "context7"
                "grep_app"
              ];
            };
            explorer = {
              model = "opencode/minimax-m2.7";
              skills = [];
              mcps = [];
            };
            designer = {
              model = "opencode/kimi-k2.6";
              variant = "medium";
              skills = [];
              mcps = [];
            };
            fixer = {
              model = "opencode/deepseek-v4-flash";
              variant = "high";
              skills = [];
              mcps = [];
            };
          };
        };
      };
    in {
      imports = [inputs.self.modules.homeManager.gitoc];
      programs = {
        opencode = {
          enable = true;
          settings = {
            model = "opencode/big-pickle";
            small_model = "opencode/big-pickle";
            command = {
              commit = {
                template = builtins.readFile ./conventional-commit-with-gitmoji-ai-prompt.md;
              };
              review = {
                template = builtins.readFile ./review_code.md;
              };
            };
            agent = {
              code-reviewer = {
                description = "Code Reviewer Agent";
                prompt = ''
                  You are a senior software engineer specializing in code reviews.
                  Focus on code quality, security, and maintainability.

                  ## Guidelines
                  - Review for potential bugs and edge cases
                  - Check for security vulnerabilities
                  - Ensure code follows best practices
                  - Suggest improvements for readability and performance
                '';
              };
              documentation = {
                description = "Documentation Agent";
                prompt = ''
                  You are an expert technical writer focused on creating clear and concise documentation.
                  Your goal is to help developers understand how to use the code effectively.

                  ## Guidelines
                  - Create user-friendly documentation
                  - Include examples and use cases
                  - Explain complex concepts in simple terms
                  - Ensure accuracy and completeness
                '';
              };
              security-auditor = {
                description = "Reviews code for quality and best practices";
                tools = {
                  write = false;
                  edit = false;
                  bash = false;
                };
                prompt = ''
                  ---
                  mode: primary
                  temperature: 0.1
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
              explore.disable = true;
              general.disable = true;
            };
            plugin = [
              "oh-my-opencode-slim"
            ];
          };
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

          packages = [
            pkgs.glow
          ];

          shellAliases = {
            review = "opencode --command review run | if [ -t 1 ]; then glow --tui -; else cat; fi";
          };
        }
        else {};
    };
  };
}
