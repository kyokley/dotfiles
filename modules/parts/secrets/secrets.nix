let
  mercury = builtins.readFile ../hosts/mercury/mercury.pub;
  mars = builtins.readFile ../hosts/mars/mars.pub;
  dioxygen = builtins.readFile ../hosts/dioxygen/dioxygen.pub;
  venus = builtins.readFile ../hosts/venus/venus.pub;
in {
  "ollama-mattermost-bot-token.age" = {
    publicKeys = [mercury mars dioxygen];
    armor = true;
  };
  "openrouter.age" = {
    publicKeys = [mercury mars dioxygen];
    armor = true;
  };
  "github-copilot.age" = {
    publicKeys = [mercury mars dioxygen];
    armor = true;
  };
  "mars-st.age" = {
    publicKeys = [mars];
    armor = true;
  };
}
