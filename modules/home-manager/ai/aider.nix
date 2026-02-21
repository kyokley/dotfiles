{
  lib,
  inputs,
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
  home = {
    file = {
      aider_settings = {
        enable = true;
        target = ".aider.model.settings.yml";
        text = aider_settings_string;
      };
    };

    sessionVariables = {
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
  };
}
