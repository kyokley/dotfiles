{
  pkgs,
  lib,
  username,
  ...
}: let
  nix-update = pkgs.writeShellScriptBin "nix-update" ''
    PATH=$PATH:${lib.makeBinPath [pkgs.nix]}
    ${pkgs.home-manager}/bin/home-manager switch --flake 'github:kyokley/dotfiles#dioxygen'
    test $(echo "$(${pkgs.home-manager}/bin/home-manager generations | wc -l) > 1" | bc) -eq 1 && ${pkgs.home-manager}/bin/home-manager expire-generations "-30 days"
    ${pkgs.nix}/bin/nix store gc
  '';
in {
  imports = [
    ../../modules/home-manager/home.nix
    ../../modules/home-manager/dev.nix
    ../../modules/home-manager/ai/ai.nix
    ../../modules/home-manager/ai/aider.nix
  ];

  programs.systemd-services.enable = false;

  home = {
    homeDirectory = "/Users/${username}";

    packages = [
      nix-update
    ];
    stateVersion = "24.05";
  };

  services.home-manager.autoUpgrade.enable = false;

  programs.git.settings.alias = {
    select = ''!echo "$(git branch | awk '{print $NF}')" "\n" "$(git branch -r | grep -v HEAD | awk '{print $NF}' | sed -E 's!^[^/]+/!!')" | sort -u | choose | xargs -r git switch'';
  };
}
