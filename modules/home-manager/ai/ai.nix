{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  gitoc = pkgs.writeShellScriptBin "gitoc" (import ./gitoc.nix {inherit pkgs;}).gitoc-script;
in {
  age.secrets = {
    openrouter.file = ../../../secrets/openrouter.age;
    github-copilot.file = ../../../secrets/github-copilot.age;
  };

  home = {
    sessionVariables = rec {
      OLLAMA_HOST = "100.92.134.123:11434";
      OLLAMA_API_BASE = "http://${OLLAMA_HOST}";
    };

    packages = [
      pkgs.ollama
      pkgs.github-copilot-cli
      gitoc
    ];
  };

  programs = {
    zsh.prezto.extraConfig = ''
      export OPENAI_API_BASE=https://api.githubcopilot.com
      export OPENAI_API_KEY=$(cat "${config.age.secrets.github-copilot.path}")
    '';

    opencode = {
      enable = true;
      settings = {
        model = "github-copilot/claude-sonnet-4.5";
        small_model = "github-copilot/claude-haiku-4.5";
      };
      commands = {
        changelog = ''
          # Update Changelog Command

          Update CHANGELOG.md with a new entry for the specified version.
          Usage: /changelog [version] [change-type] [message]
        '';
        commit = ./conventional-commit-with-gitmoji-ai-prompt.md;
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
