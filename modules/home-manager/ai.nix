{
  programs.aider-chat.enable = true;
  home.sessionVariables = {
    OLLAMA_API_BASE = "http://100.92.134.123:11434";
    NIXVIM_AIDER_MODEL = "ollama_chat/gpt-oss";
    # NIXVIM_AIDER_MODEL = "ollama_chat/llama3.2:3b";
  };
}
