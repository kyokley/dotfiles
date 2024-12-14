{ pkgs, ... }:
let
  csd-post = pkgs.writeShellScriptBin "csd-post" (builtins.readFile ./csd-post.sh);
in
{
  environment.systemPackages = [
    csd-post
  ];
}
