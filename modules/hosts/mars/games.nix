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
    mkN64Game = attrs: (pkgs.writeShellApplication {
      inherit (attrs) name;
      text = ''
        n64 --fullscreen ${attrs.rom}
      '';
    });
  in {
    home.packages = with pkgs;
      [
        n64
        goldeneye
        lutris
        steam
        mupen64plus
      ]
      ++ (map mkN64Game [
        {
          name = "goldeneye";
          rom = "${config.home.homeDirectory}/Games/goldeneye-007/Msftug41.v64";
        }
        {
          name = "starfox";
          rom = "${config.home.homeDirectory}/Games/Nintendo64-N64.SCENE.ARCHIVE.-.COMPLETE/Starfox_64-MSFTUG/Msftug30.v64";
        }
      ]);
  };
}
