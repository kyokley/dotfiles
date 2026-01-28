{
  pkgs,
  inputs,
  ...
}: {
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
  home.sessionVariables = rec {
    OLLAMA_HOST = "100.92.134.123:11434";
    OLLAMA_API_BASE = "http://${OLLAMA_HOST}";
    # NIXVIM_AIDER_MODEL = "ollama_chat/gpt-oss";
    # NIXVIM_AIDER_MODEL = "ollama_chat/llama3.2:3b";
    # NIXVIM_AIDER_MODEL = "ollama_chat/qwen3:8b";
    NIXVIM_AIDER_MODEL = "ollama_chat/qwen3-coder:30b";
    # AIDER_COMMIT_MODEL = "ollama_chat/llama3.2:3b";
    AIDER_COMMIT_MODEL = "ollama_chat/qwen3:8b";
  };

  home.packages = [
    inputs.aider-commit.packages.${pkgs.stdenv.hostPlatform.system}.gitac
  ];
}
