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

    home.packages = [
        pkgs.devenv
        pkgs.dotnetCorePackages.dotnet_8.sdk
        nix-update
    ];

    # nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg)
    # [ "vscode" ];

    programs.nixvim.installType = "dos";

    programs.git.userEmail = "kyokley@revantage.com";
    programs.git.extraConfig = {
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
}
