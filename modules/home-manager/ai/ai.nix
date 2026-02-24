{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    ./opencode.nix
  ];

  home = {
    packages = [
      pkgs.github-copilot-cli
    ];
  };
}
