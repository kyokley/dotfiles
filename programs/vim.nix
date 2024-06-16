{config, lib, pkgs, ...}:
let
    cfg = config.programs.nixvim;
    # mkIfElse = p: yes: no: lib.mkMerge [
    #     (lib.mkIf p yes)
    #     (lib.mkIf (!p) no)
    # ];
in
{
    options.programs.nixvim = {
        enable = lib.mkEnableOption "nixvim";

        installType = lib.mkOption {
            default = "default";
            type = lib.types.str;
            description = ''
                Type of nixvim install to use. Either default, dos, or minimal.
            '';
        };
    };

    config = {
        home.packages = [
           pkgs.universal-ctags
        ];
        programs.git.extraConfig.core.editor = "nix run 'github:kyokley/nixvim#${cfg.installType}' --";
        programs.zsh.shellGlobalAliases = {
            vim = "nix run 'github:kyokley/nixvim#${cfg.installType}' --";
        };

        home.sessionVariables = {
            EDITOR = "nix run 'github:kyokley/nixvim#${cfg.installType}' --";
            VISUAL = "nix run 'github:kyokley/nixvim#${cfg.installType}' --";
        };
    };
}
