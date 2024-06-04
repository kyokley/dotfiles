{lib, ...}:
{
  programs.nixvim.enable = false;
  programs.git.userEmail = "kyokley@jupiter";

  programs.zsh.prezto.extraConfig = [
        ''
        function mc-run() {
            cd ~/workspace/MediaConverterProd
            make mc-run
            cd -
        }
        ''
  ];
}
