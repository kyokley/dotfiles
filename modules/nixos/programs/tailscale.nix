{pkgs-unstable, ...}: {
  # Enable tailscale
  services.tailscale = {
    enable = true;
    package = pkgs-unstable.tailscale;
    useRoutingFeatures = "both";
  };
  networking.nameservers = [
    "100.124.31.71"
  ];

  # Enable trayscale once added to home-manager
  # services.trayscale.enable = false;
  environment.systemPackages = [
    pkgs-unstable.tailscale
  ];
}
