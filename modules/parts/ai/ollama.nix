let
  _ollama = {
    age.secrets = {
      openrouter.file = ../../../secrets/openrouter.age;
      github-copilot.file = ../../../secrets/github-copilot.age;
    };

    home = {
      sessionVariables = rec {
        OLLAMA_HOST = "100.92.134.123:11434";
        OLLAMA_API_BASE = "http://${OLLAMA_HOST}";
      };
    };
  };
in {
  flake.modules.homeManager = {
    ollama = _ollama;
  };
}
