{ pkgs, lib, ... }:
let
  nix-update = pkgs.writeShellScriptBin "nix-update" ''
    PATH=$PATH:${lib.makeBinPath [ pkgs.nix ]}
    ${pkgs.home-manager}/bin/home-manager switch --flake 'github:kyokley/dotfiles#saturn'
    test $(echo "$(${pkgs.home-manager}/bin/home-manager generations | wc -l) > 1" | bc) -eq 1 && ${pkgs.home-manager}/bin/home-manager expire-generations "-30 days"
    ${pkgs.nix}/bin/nix store gc
  '';
in
{
    programs.systemd-services.enable = false;

    imports = [
      ../home.nix
    ];

    home.packages = [
        pkgs.devenv
        pkgs.dotnetCorePackages.dotnet_8.sdk
        pkgs.xfce.thunar
        pkgs.xsel
        nix-update
        pkgs.python311Packages.bpython
    ];

    programs.git.userEmail = "kyokley@revantage.com";
    programs.git.extraConfig = {
      core.autocrlf = true;
      credential = {
        helper = "/home/yokley/WinGit/mingw64/bin/git-credential-manager.exe";
        useHttpPath = true;
        # url."https://dev.azure.com" = {
        #   useHttpPath = true;
        # };
      };
    };

    home.shellAliases = {
        run-proxy = "cd /home/yokley/repos/tailscale-proxy && make up; make down; cd -";
        explore = "explorer.exe .";
    };

    home.stateVersion = "23.11"; # Please read the comment before changing.
}
