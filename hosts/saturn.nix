{ pkgs, ... }:
{
    programs.systemd-services.environment = "saturn";

    home.packages = [
        pkgs.dotnetCorePackages.dotnet_8.sdk
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
