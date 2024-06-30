{ pkgs, lib, ... }:
let
  nix-update = pkgs.writeShellScriptBin "nix-update" ''
    PATH=$PATH:${lib.makeBinPath [ pkgs.nix ]}
    ${pkgs.home-manager}/bin/home-manager switch --flake 'github:kyokley/dotfiles#dioxygen'
    test $(echo "$(${pkgs.home-manager}/bin/home-manager generations | wc -l) > 1" | bc) -eq 1 && ${pkgs.home-manager}/bin/home-manager expire-generations "-30 days"
    ${pkgs.nix}/bin/nix store gc
  '';
in
{
  programs.systemd-services.enable = false;

  home.homeDirectory = "/Users/yokley";

  home.packages = [
    pkgs.devenv
    nix-update
  ];

  services.home-manager.autoUpgrade.enable = false;
}
