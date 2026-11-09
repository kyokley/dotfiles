{
  flake.modules.homeManager.chrome = {pkgs, ...}: {
    home.packages = [
      pkgs.chromium
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = ["chromium.desktop"];
        "text/html" = ["chromium.desktop"];
        "x-scheme-handler/http" = ["chromium.desktop"];
        "x-scheme-handler/https" = ["chromium.desktop"];
      };
    };
  };
}
