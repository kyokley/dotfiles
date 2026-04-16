{
  inputs,
  den,
  lib,
  ...
}: let
  initialUser = "yokley";
in {
  imports = [inputs.den.flakeModule];
}
