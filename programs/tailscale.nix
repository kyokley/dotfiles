{pkgs, ...}: {
  # Enable tailscale
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  networking.nameservers = [
    "100.124.31.71"
  ];

  # Enable trayscale once added to home-manager
  # services.trayscale.enable = false;
  environment.systemPackages = with pkgs; [
    tailscale
  ];
}
