{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  age.secrets.openrouter.file = ../../secrets/openrouter.age;

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

  home.activation."openrouter-secret" = ''
    secret=$(cat "${config.age.secrets.openrouter.path}")
    configFile="${lib.removePrefix config.home.homeDirectory config.xdg.configHome}/aichat/config.yaml"
    ${pkgs.gnused}/bin/sed -i "s#@api_key@#$secret#" "$configFile"
  '';

  programs.aichat = {
    enable = true;
    agents = {
      gpt = {
        model = "ollama:gpt-oss";
        temperature = 0.5;
        use_tools = "web_search";
        agent_prelude = ''
        '';
      };
      llama = {
        model = "ollama:llama3.2:3b";
        temperature = 0.5;
        use_tools = "web_search";
      };
      coder = {
        model = "ollama:qwen3-coder:30b";
        temperature = 0.5;
        use_tools = "web_search";
      };
      # OpenRouter agents
      openrouter-gpt-4 = {
        model = "openrouter/openai/gpt-4";
        temperature = 0.5;
        use_tools = "web_search";
      };
      openrouter-gpt-4-turbo = {
        model = "openrouter/openai/gpt-4-turbo";
        temperature = 0.5;
        use_tools = "web_search";
      };
      openrouter-gpt-3-5 = {
        model = "openrouter/openai/gpt-3.5-turbo";
        temperature = 0.5;
        use_tools = "web_search";
      };
      openrouter-llama-3-70b = {
        model = "openrouter/meta-llama/llama-3-70b-instruct";
        temperature = 0.5;
        use_tools = "web_search";
      };
      openrouter-mistral-7b = {
        model = "openrouter/mistralai/mistral-7b-instruct";
        temperature = 0.5;
        use_tools = "web_search";
      };
    };

    settings = {
      model = "ollama:gpt-oss";
      clients = [
        {
          type = "openai-compatible";
          name = "ollama";
          api_base = "http://${config.home.sessionVariables.OLLAMA_HOST}/v1";
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
              supports_reasoning = true;
              supports_vision = false;
            }
          ];
        }
        {
          type = "openai";
          name = "openrouter";
          api_base = "https://openrouter.ai/api/v1";
          api_key = "@api_key@"; # This should be set in environment variables
          models = [
            {
              name = "openai/gpt-4";
              supports_function_calling = true;
              supports_vision = true;
            }
            {
              name = "openai/gpt-4-turbo";
              supports_function_calling = true;
              supports_vision = true;
            }
            {
              name = "openai/gpt-3-5-turbo";
              supports_function_calling = true;
              supports_vision = false;
            }
            {
              name = "meta-llama/llama-3-70b-instruct";
              supports_function_calling = true;
              supports_vision = false;
            }
            {
              name = "mistralai/mistral-7b-instruct";
              supports_function_calling = true;
              supports_vision = false;
            }
          ];
        }
      ];
    };
  };
}
