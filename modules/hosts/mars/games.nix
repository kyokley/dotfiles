{
  flake.modules.homeManager."yokley@mars" = {
    pkgs,
    config,
    ...
  }: let
    n64 = pkgs.writeShellApplication {
      name = "n64";
      text = ''
        exec ${pkgs.mupen64plus}/bin/mupen64plus --datadir "${config.home.homeDirectory}/.local/share/mupen64plus/data" "$@"
      '';
    };
    goldeneye = pkgs.writeShellApplication {
      name = "goldeneye";
      text = ''
        n64 --fullscreen ${config.home.homeDirectory}/Games/goldeneye-007/Msftug41.v64
      '';
    };
  in {
    home.packages = with pkgs; [
      n64
      goldeneye
      lutris
      steam
      mupen64plus
    ];
  };
}
