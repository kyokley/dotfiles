{
  flake.modules.homeManager."yokley@mars" = {
    pkgs,
    config,
    ...
  }: let
    gameDir = "${config.home.homeDirectory}/Games";
    n64 = pkgs.writeShellApplication {
      name = "n64";
      text = ''
        exec ${pkgs.mupen64plus}/bin/mupen64plus --datadir "${config.home.homeDirectory}/.local/share/mupen64plus/data" "$@"
      '';
    };
    mkN64Game = attrs: (pkgs.writeShellApplication {
      inherit (attrs) name;
      text = ''
        ${n64}/bin/n64 --fullscreen ${attrs.rom}
      '';
    });
  in {
    home.packages = with pkgs;
      [
        n64
        lutris
        steam
        mupen64plus
      ]
      ++ (map mkN64Game [
        {
          name = "goldeneye";
          rom = "${gameDir}/goldeneye-007/Msftug41.v64";
        }
        {
          name = "starfox";
          rom = "${gameDir}/N64/Starfox_64_USA-MSFTUG/Msftug34.v64";
        }
        {
          name = "tetrisphere";
          rom = "${gameDir}/tetrisphere/Tetris.v64";
        }
        {
          name = "hockey";
          rom = "${gameDir}/wayne-gretzkys-3d-hockey/As-wg3dh.v64";
        }
        {
          name = "wcw";
          rom = "${gameDir}/wcwnwo-revenge/AGS-WCWR.V64";
        }
        {
          name = "zelda";
          rom = "${gameDir}/Legend_of_Zelda-Ocarina_of_Time_v1.2_USA-TC/tc-zld12.rom";
        }
      ]);
  };
}
