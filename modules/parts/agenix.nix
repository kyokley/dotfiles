{inputs, ...}: {
  flake.modules.homeManager.common = {pkgs, ...}: {
    imports = [
      inputs.agenix.homeManagerModules.default
    ];

    home.packages = [
      pkgs.ragenix
    ];

    age = {
      secrets = {
        ollama-mattermost-bot-token = {
          file = ./secrets/ollama-mattermost-bot-token.age;
        };
        mars-st = {
          file = ./secrets/mars-st.age;
        };
      };
    };
  };
}
