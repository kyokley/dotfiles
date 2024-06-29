{ lib, ... }:
with lib;
{
    options.variables = {
        environment = mkOption {
            type = type.str;
            default = "default";
            description = "Name of the environment being installed on";
        };
    };
}
