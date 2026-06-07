{config, ...}: let
  _opencode = {
    pkgs,
    inputs,
    config,
    lib,
    ...
  }: let
    npm_deps = pkgs.callPackage ./_default.nix {
      inherit (inputs.bun2nix.packages.${pkgs.stdenv.hostPlatform.system}) bun2nix default;
    };
  in {
    imports = [inputs.self.modules.homeManager.gitoc];
    programs = {
      opencode = {
        enable = true;
        settings = {
          model = "opencode/claude-haiku-4-5";
          small_model = "opencode/claude-haiku-4-5";
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
            source = ./oh-my-opencode-slim.json;
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
in {
  flake.modules.homeManager = {
    opencode = _opencode;
  };
}
