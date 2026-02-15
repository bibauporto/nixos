{
  config,
  pkgs,
  lib,
  ...
}:
{
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/sbctl"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/docker"
      /var/lib/flatpak
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.LEA.directories = [
      "Documents"
      "Downloads"
      "Code"
      ".config"
      ".pki"
      ".ssh"
      ".local/share"

      ################
      # CACHE
      ".cache"
      #################

      ################
      # APPs
      ".antigravity"
      ".gemini"
      ".bun"
      ".vscode"
      ###############

      ###############
      # FLATPAK
      ".var/app"
      ###############

      ".gnupg"
    ];
  };
}
