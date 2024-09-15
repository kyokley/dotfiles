{
  description = "NixOS Flake";

  # The nixpkgs entry in the flake registry.
  inputs.nixpkgsRegistry.url = "nixpkgs";

  inputs.nixpkgsGitHubBranch.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs = all@{ self, nixpkgs, ... }:
  let
    # Should match above nixpkgs version
    stateVersion = "24.05";
  in
  {

    # Used with `nixos-rebuild --flake .#<hostname>`
    # nixosConfigurations."<hostname>".config.system.build.toplevel must be a derivation
    nixosConfigurations = {
      mars = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./common-configuration.nix
          ../../hosts/mars/configuration.nix
          ../../hosts/mars/hardware-configuration.nix
          {
            system.stateVersion = "${stateVersion}";
          }
        ] ;
      };
      mercury = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./common-configuration.nix
          ../../hosts/mercury/configuration.nix
          ../../hosts/mercury/hardware-configuration.nix
          {
            system.stateVersion = "${stateVersion}";
          }
        ] ;
      };
    };

  };
}
