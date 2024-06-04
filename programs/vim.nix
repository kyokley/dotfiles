{config, lib, pkgs, ...}:
let
    cfg = config.programs.nixvim;
in
{
    options.programs.nixvim = {
        enable = lib.mkEnableOption "nixvim";

        installType = lib.mkOption {
            default = "default";
            type = lib.types.str;
            description = ''
                Type of nixvim install to use. Either default or minimal.
            '';
        };
    };

    config = if cfg.enable
    then {
        home.packages = [
           pkgs.universal-ctags
        ];
        programs.git.extraConfig.core.editor = "nix run 'github:kyokley/nixvim#${cfg.installType}' --";
        programs.zsh.shellGlobalAliases = {
            vim = "nix run 'github:kyokley/nixvim#${cfg.installType}' --";
        };
    }
    else
    {
        home.packages = [
           pkgs.neovim
        ];

        programs.zsh.shellGlobalAliases = {
            vim = "nvim";
        };
    };
}
