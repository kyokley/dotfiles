{
  pkgs,
  inputs,
  config,
  ...
}: {
  home.sessionVariables = rec {
    OLLAMA_HOST = "100.92.134.123:11434";
    OLLAMA_API_BASE = "http://${OLLAMA_HOST}";
    # NIXVIM_AIDER_MODEL = "ollama_chat/gpt-oss";
    # NIXVIM_AIDER_MODEL = "ollama_chat/llama3.2:3b";
    # NIXVIM_AIDER_MODEL = "ollama_chat/qwen3:8b";
    NIXVIM_AIDER_MODEL = "ollama_chat/qwen3-coder:30b";
    NIXVIM_AIDER_EXTRA_ARGS = "--no-stream";
    # AIDER_COMMIT_MODEL = "ollama_chat/llama3.2:3b";
    AIDER_COMMIT_MODEL = "ollama_chat/qwen3:8b";
  };

  home.packages = [
    inputs.aider-commit.packages.${pkgs.stdenv.hostPlatform.system}.gitac
  ];

  programs.aider-chat = {
    enable = true;
    settings = {
      model = "ollama_chat/gpt-oss";
      gitignore = false;
      notifications = true;
    };
  };

  programs.git = {
    ignores = [
      ".aider*"
    ];
  };

  programs.aichat = {
    enable = true;
    settings = {
      model = "ollama:gpt-oss";
      clients = [
        {
          type = "openai-compatible";
          name = "ollama";
          api_base = "http://${config.home.sessionVariables.OLLAMA_HOST}:11434";
          models = [
            {
              name = "llama3.2:3b";
              supports_function_calling = false;
              supports_vision = false;
            }
            {
              name = "gpt-oss";
              supports_function_calling = false;
              supports_vision = false;
            }
            {
              name = "qwen3:8b";
              supports_function_calling = false;
              supports_vision = false;
            }
            {
              name = "qwen3-coder:30b";
              supports_function_calling = true;
              supports_vision = false;
            }
            {
              name = "gemma3:12b";
              supports_function_calling = false;
              supports_vision = false;
            }
            {
              name = "deepseek-r1:32b";
              supports_function_calling = true;
              supports_vision = false;
            }
          ];
        }
      ];
    };
  };
}
