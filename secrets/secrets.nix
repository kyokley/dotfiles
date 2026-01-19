let
  mercury = builtins.readFile ../hosts/mercury/mercury.pub;
  mars = builtins.readFile ../hosts/mars/mars.pub;
  dioxygen = builtins.readFile ../hosts/dioxygen/dioxygen.pub;
in
{
  "ollama-mattermost-bot-token.age" = {
    publicKeys = [mercury mars dioxygen];
    armor = true;
  };
}
