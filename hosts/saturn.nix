{
    programs.git.userEmail = "kyokley@revantage.com";
    programs.git.extraConfig = {
      core = {
        editor = "nix run github:kyokley/nixvim --";
        autocrlf = "input";
      };
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
