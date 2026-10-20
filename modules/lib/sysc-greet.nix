upstream: let
  nixpkgs = upstream.inputs.nixpkgs;
  legacyPackages = builtins.mapAttrs (system: _:
    import nixpkgs {
      inherit system;
      # Permit only this unfree package in the upstream package set.
      config = {
        allowUnfree = false;
        allowUnfreePredicate = pkg: nixpkgs.lib.getName pkg == "sysc-greet";
      };
    })
  nixpkgs.legacyPackages;
  outputs = (import "${upstream}/flake.nix").outputs (upstream.inputs
    // {
      nixpkgs = nixpkgs // {inherit legacyPackages;};
      # The upstream module refers to its own outputs while constructing outputs.
      self = upstream // outputs;
    });
in
  outputs
