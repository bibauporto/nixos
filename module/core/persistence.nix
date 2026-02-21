{
  ...
}:
{
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/etc/NetworkManager/system-connections"

      # Docker
      "/var/lib/docker" # Docker

      # Lanzaboot
      "/etc/secureboot"
      "/var/lib/sbctl"

      # FLATPAK
      # "/var/lib/flatpak"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.lea.directories = [
      "Documents"
      "Downloads"
      "Code"
      ".config"
      ".pki"
      ".ssh"
      ".local/share"

      # CACHE
      ".cache"

      # APPs
      # ".antigravity"
      ".gemini" # used for vscode gemini extension
      ".bun"
      ".vscode"

      # FLATPAK
      # ".var/app"

      # ".gnupg"
    ];
  };
}
