# network.nix
{
  lib,
  ...
}:

{
  # Networking configuration
  networking.hostName = "lea-pc";
  networking.useDHCP = lib.mkDefault false;
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  # DNS Resolver (systemd-resolved)
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNSSEC = "false";
        Domains = [ "~." ];
        FallbackDNS = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
    };
  };

  # Firewall (NixOS alternative to UFW)
  networking.firewall = {
    enable = true;
    # Allow common ports
    allowedTCPPorts = [
      22
      80
      443
    ];
    allowedUDPPorts = [ ];
  };
}
