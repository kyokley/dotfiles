{
    programs.git.extraConfig.core.editor = "nix run 'github:kyokley/nixvim#minimal' --";
    programs.zsh.shellGlobalAliases = {
        vim = "nix run 'github:kyokley/nixvim#minimal' --";
    };
}
