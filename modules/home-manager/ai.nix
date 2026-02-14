{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  age.secrets.openrouter.file = ../../secrets/openrouter.age;

  home = {
    sessionVariables = rec {
      OLLAMA_HOST = "100.92.134.123:11434";
      OLLAMA_API_BASE = "http://${OLLAMA_HOST}";
      # NIXVIM_AIDER_MODEL = "ollama_chat/gpt-oss";
      # NIXVIM_AIDER_MODEL = "ollama_chat/llama3.2:3b";
      # NIXVIM_AIDER_MODEL = "ollama_chat/qwen3:8b";
      # NIXVIM_AIDER_MODEL = "ollama_chat/qwen3-coder:30b";
      # NIXVIM_AIDER_EXTRA_ARGS = "--no-stream";

      NIXVIM_AIDER_MODEL = "openrouter/meta-llama/llama-3.3-70b-instruct:free";

      # AIDER_COMMIT_MODEL = "ollama_chat/llama3.2:3b";
      # AIDER_COMMIT_MODEL = "ollama_chat/qwen3:8b";
      AIDER_COMMIT_MODEL = "openrouter/meta-llama/llama-3.3-70b-instruct:free";
    };

    packages = [
      inputs.aider-commit.packages.${pkgs.stdenv.hostPlatform.system}.gitac
      pkgs.ollama
      pkgs.github-copilot-cli
    ];
  };

  programs = {
    aider-chat = {
      enable = true;
      settings = {
        model = "openrouter/meta-llama/llama-3.3-70b-instruct:free";
        gitignore = false;
        notifications = true;
      };
    };

    git = {
      ignores = [
        ".aider*"
      ];
    };

    # home.activation."openrouter-secret" = ''
    #   secret=$(cat "${config.age.secrets.openrouter.path}")
    #   configFile="${lib.removePrefix config.home.homeDirectory config.xdg.configHome}/aichat/config.yaml"
    #   ${pkgs.gnused}/bin/sed -i "s#@api_key@#$secret#" "$configFile"
    # '';
    zsh.prezto.extraConfig = ''
      export OPENROUTER_API_KEY=$(cat "${config.age.secrets.openrouter.path}")
      export AICHAT_PLATFORM="openrouter"
      export AICHAT_MODEL=openrouter:meta-llama/llama-3.3-70b-instruct:free
    '';

    aichat = {
      enable = true;
      # agents = {
      #   foo = {
      #     model = "openrouter:google/gemma-3n-e2b-it:free";
      #     name = "foo";
      #     temperature = 0.5;
      #     use_tools = "web_search";
      #   };
      # };

      #    settings = {
      #      model = "ollama:gpt-oss";
      #      clients = [
      #        {
      #          type = "openai-compatible";
      #          name = "ollama";
      #          api_base = "http://${config.home.sessionVariables.OLLAMA_HOST}/v1";
      #          models = [
      #            {
      #              name = "llama3.2:3b";
      #              supports_function_calling = false;
      #              supports_vision = false;
      #            }
      #            {
      #              name = "gpt-oss";
      #              supports_function_calling = false;
      #              supports_vision = false;
      #            }
      #            {
      #              name = "qwen3:8b";
      #              supports_function_calling = false;
      #              supports_vision = false;
      #            }
      #            {
      #              name = "qwen3-coder:30b";
      #              supports_function_calling = true;
      #              supports_vision = false;
      #            }
      #            {
      #              name = "gemma3:12b";
      #              supports_function_calling = false;
      #              supports_vision = false;
      #            }
      #            {
      #              name = "deepseek-r1:32b";
      #              supports_function_calling = true;
      #              supports_reasoning = true;
      #              supports_vision = false;
      #            }
      #          ];
      #        }
      #        {
      #          type = "openai";
      #          name = "openrouter";
      #          api_base = "https://openrouter.ai/api/v1";
      #          api_key = "@api_key@"; # This should be set in environment variables
      #          models = [
      #            {
      #              name = "openai/gpt-4";
      #              supports_function_calling = true;
      #              supports_vision = true;
      #            }
      #            {
      #              name = "openai/gpt-4-turbo";
      #              supports_function_calling = true;
      #              supports_vision = true;
      #            }
      #            {
      #              name = "openai/gpt-3-5-turbo";
      #              supports_function_calling = true;
      #              supports_vision = false;
      #            }
      #            {
      #              name = "meta-llama/llama-3-70b-instruct";
      #              supports_function_calling = true;
      #              supports_vision = false;
      #            }
      #            {
      #              name = "mistralai/mistral-7b-instruct";
      #              supports_function_calling = true;
      #              supports_vision = false;
      #            }
      #          ];
      #        }
      #      ];
      #    };
    };

    fabric-ai = {
      enable = true;
      enablePatternsAliases = false;
      enableYtAlias = true;
      enableZshIntegration = true;
    };

    yt-dlp.enable = true;

    gemini-cli = {
      enable = true;
    };

    opencode = {
      enable = true;
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
        # documentation = ./agents/documentation.md;
      };
    };
  };
}
