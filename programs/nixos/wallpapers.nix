{
  pkgs,
  clonix,
  ...
}: let
  homeDir = "/home/yokley";
  remoteWallpaperHost = "jupiter";
  sync-wallpapers = pkgs.writeScriptBin "sync-wallpapers" ''
    set -x
    ${pkgs.rsync}/bin/rsync -ruv ${remoteWallpaperHost}:${homeDir}/Pictures/wallpapers ${homeDir}/Pictures/
    ${pkgs.rsync}/bin/rsync -ruv ${homeDir}/Pictures/wallpapers ${remoteWallpaperHost}:${homeDir}/Pictures/
  '';
in {
  imports = [
    clonix.homeManagerModules.clonix
  ];

  home.packages = [
    sync-wallpapers
  ];

  services.clonix = {
    enable = true;
    deployments = [
      {
        deploymentName = "localToRemote";
        source.dir = "yokley@jupiter:${homeDir}/Pictures/wallpapers";
        targetDir = "${homeDir}/Pictures/";
        remote.enable = false;
        remote.user.name = "yokley";
        remote.ipOrHostname = remoteWallpaperHost;
        timer.enable = true;
        timer.Persistent = true;
        timer.OnCalendar = "daily";
        extraOptions = "--timeout=10 --rsh=\"${pkgs.openssh}/bin/ssh -o 'StrictHostKeyChecking=no'\"";
      }
    ];
  };

  home.file.wallpapers = {
    enable = true;
    target = "Pictures/wallpapers/.keep";
    text = "";
  };
}
