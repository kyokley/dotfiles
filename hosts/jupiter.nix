{lib, ...}:
{
  programs.systemd-services.environment = "jupiter";

  programs.nixvim.enable = false;
  programs.git.userEmail = "kyokley@jupiter";

  programs.zsh.prezto.extraConfig = lib.mkAfter
        ''
        function mc-run() {
            cd ~/workspace/MediaConverterProd
            make run
            cd -
        }
        '';
}
