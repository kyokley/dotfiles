{
  flake.modules.homeManager.brave = {pkgs, ...}: {
    home.packages = [
      pkgs.brave
    ];

    # Uncomment to allow brave to open links
    # xdg.mimeApps = {
    #   enable = true;
    #   defaultApplications = {
    #     "application/pdf" = ["brave-browser.desktop"];
    #     "text/html" = ["brave-browser.desktop"];
    #     "x-scheme-handler/http" = ["brave-browser.desktop"];
    #     "x-scheme-handler/https" = ["brave-browser.desktop"];
    #   };
    # };
  };
}
