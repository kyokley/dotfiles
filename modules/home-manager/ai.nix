{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  age.secrets = {
    openrouter.file = ../../secrets/openrouter.age;
    github-copilot.file = ../../secrets/github-copilot.age;
  };

  home = {
    sessionVariables = rec {
      OLLAMA_HOST = "100.92.134.123:11434";
      OLLAMA_API_BASE = "http://${OLLAMA_HOST}";
      # NIXVIM_AIDER_MODEL = "ollama_chat/gpt-oss";
      # NIXVIM_AIDER_MODEL = "ollama_chat/llama3.2:3b";
      # NIXVIM_AIDER_MODEL = "ollama_chat/qwen3:8b";
      # NIXVIM_AIDER_MODEL = "ollama_chat/qwen3-coder:30b";
      # NIXVIM_AIDER_EXTRA_ARGS = "--no-stream";

      # NIXVIM_AIDER_MODEL = "openrouter/meta-llama/llama-3.3-70b-instruct:free";
      NIXVIM_AIDER_MODEL = "claude-sonnet-4.5";

      # AIDER_COMMIT_MODEL = "ollama_chat/llama3.2:3b";
      # AIDER_COMMIT_MODEL = "ollama_chat/qwen3:8b";
      # AIDER_COMMIT_MODEL = "openrouter/meta-llama/llama-3.3-70b-instruct:free";
      AIDER_COMMIT_MODEL = "gpt-5-mini";
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
        model = "claude-sonnet-4.5";
        gitignore = false;
        notifications = true;
      };
    };

    git = {
      ignores = [
        ".aider*"
      ];
    };

    zsh.prezto.extraConfig = ''
      # export OPENROUTER_API_KEY=$(cat "${config.age.secrets.openrouter.path}")
      # export AICHAT_PLATFORM="openrouter"
      # export AICHAT_MODEL=openrouter:meta-llama/llama-3.3-70b-instruct:free
      export OPENAI_API_BASE=https://api.githubcopilot.com
      export OPENAI_API_KEY=$(cat "${config.age.secrets.github-copilot.path}")
    '';

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
