{bun2nix, ...}:
bun2nix.mkDerivation {
  # pname = "opencode deps";
  # version = "1.0.0";

  packageJson = ./package.json;
  src = ./.;

  bunDeps = bun2nix.fetchBunDeps {
    bunNix = ./_bun.nix;
  };

  module = "package.json";
}
