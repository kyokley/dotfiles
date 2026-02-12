{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    bitwarden-desktop
  ];

  services = {
    # Enable below for fingerprint support
    fprintd = {
      enable = false;
      tod = {
        enable = true;
        driver = pkgs.libfprint-2-tod1-goodix;
      };
    };
  };
}
