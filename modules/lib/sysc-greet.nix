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
  upstreamOutputs = (import "${upstream}/flake.nix").outputs (upstream.inputs
    // {
      nixpkgs = nixpkgs // {inherit legacyPackages;};
      # The upstream module refers to its own outputs while constructing outputs.
      self = upstream // outputs;
    });
  outputs =
    upstreamOutputs
    // {
      packages = builtins.mapAttrs (system: packages:
        packages
        // {
          default =
            if (upstream.rev or "") == "fc406221767da5557bace80e455db6312aac44bd"
            then packages.default.overrideAttrs (_: {vendorHash = "sha256-0746t7tudK0eM5wk9xblr+dhdDsxfluQ9VPLv1hFnMI=";})
            else packages.default;
        })
      upstreamOutputs.packages;
    };
in
  outputs
