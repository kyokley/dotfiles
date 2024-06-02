{config, lib, ...}:
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

    config = lib.mkIf cfg.enable {
        programs.git.extraConfig.core.editor = "nix run 'github:kyokley/nixvim#${cfg.installType}' --";
        programs.zsh.shellGlobalAliases = "nix run 'github:kyokley/nixvim#${cfg.installType}' --";
    };
}
