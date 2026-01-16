{
  programs.aider-chat.enable = true;
  home.sessionVariables = {
    OLLAMA_HOST = "100.92.134.123:11434";
    OLLAMA_API_BASE = "http://${OLLAMA_HOST}";
    # NIXVIM_AIDER_MODEL = "ollama_chat/gpt-oss";
    NIXVIM_AIDER_MODEL = "ollama_chat/llama3.2:3b";
  };
}
