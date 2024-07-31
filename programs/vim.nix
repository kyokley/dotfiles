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

        extraOptionsStr = lib.mkOption {
            default = "";
            type = lib.types.str;
            description = ''
                String of extra options to pass to nix run call
            '';
        };
    };

    config = {
        home.packages = [
           pkgs.universal-ctags
        ];
        programs.git.extraConfig.core.editor = "nix run 'github:kyokley/nixvim#${cfg.installType}' ${cfg.extraOptionsStr} --";
        programs.zsh.shellGlobalAliases = {
            vim = "nix run 'github:kyokley/nixvim#${cfg.installType}' ${cfg.extraOptionsStr} --";
        };

        home.sessionVariables = {
            EDITOR = "nix run 'github:kyokley/nixvim#${cfg.installType}' ${cfg.extraOptionsStr} --";
            VISUAL = "nix run 'github:kyokley/nixvim#${cfg.installType}' ${cfg.extraOptionsStr} --";
        };
    };
}
