{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  copilot_models = [
    "github_copilot/claude-sonnet-4.5"
    "github_copilot/gpt-5-mini"
  ];
  aider_settings_string = lib.concatStringsSep "\n" (map (
      model: ''
        - name: ${model}
          extra_params:
            extra_headers:
              User-Agent: GithubCopilot/1.155.0
              Editor-Plugin-Version: copilot/1.155.0
              Editor-Version: vscode/1.85.1
              Copilot-Integration-Id: copilot-chat
      ''
    )
    copilot_models);
in {
  age.secrets = {
    openrouter.file = ../../secrets/openrouter.age;
    github-copilot.file = ../../secrets/github-copilot.age;
  };

  home = {
    file = {
      aider_settings = {
        enable = true;
        target = ".aider.model.settings.yml";
        text = aider_settings_string;
      };
    };
    sessionVariables = rec {
      OLLAMA_HOST = "100.92.134.123:11434";
      OLLAMA_API_BASE = "http://${OLLAMA_HOST}";
      # NIXVIM_AIDER_MODEL = "ollama_chat/gpt-oss";
      # NIXVIM_AIDER_MODEL = "ollama_chat/llama3.2:3b";
      # NIXVIM_AIDER_MODEL = "ollama_chat/qwen3:8b";
      # NIXVIM_AIDER_MODEL = "ollama_chat/qwen3-coder:30b";
      # NIXVIM_AIDER_EXTRA_ARGS = "--no-stream";

      # NIXVIM_AIDER_MODEL = "openrouter/meta-llama/llama-3.3-70b-instruct:free";
      NIXVIM_AIDER_MODEL = "github_copilot/claude-sonnet-4.5";

      # AIDER_COMMIT_MODEL = "ollama_chat/llama3.2:3b";
      # AIDER_COMMIT_MODEL = "ollama_chat/qwen3:8b";
      # AIDER_COMMIT_MODEL = "openrouter/meta-llama/llama-3.3-70b-instruct:free";

      AIDER_COMMIT_MODEL = "github_copilot/gpt-5-mini";
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
        model = "github_copilot/claude-sonnet-4.5";
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
      commands = {
        changelog = ''
          # Update Changelog Command

          Update CHANGELOG.md with a new entry for the specified version.
          Usage: /changelog [version] [change-type] [message]
        '';
        commit = ''
          # Commit Command

          Create a git commit with proper message formatting.
          Usage: /commit [message]
        '';
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
        # documentation = ./agents/documentation.md;
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
          tools:
            write: false
            edit: false
            bash: false
          ---
          # Security Auditor Agent

          You are a cybersecurity expert specializing in code security audits.
          Your primary focus is identifying and mitigating security risks in codebases.

          ## Guidelines
          - Identify potential security vulnerabilities
          - Assess the impact and likelihood of each vulnerability
          - Provide actionable recommendations for mitigation
          - Stay up-to-date with the latest security threats and best practices
        '';
      };
    };
  };
}
