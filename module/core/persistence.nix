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
      "/var/lib/docker" 

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

      #Stremio
      ".stremio-server"

      # APPs
      ".antigravity"
      ".gemini" 
      ".bun"
      ".vscode"

      # FLATPAK
      # ".var/app"
    ];
  };
}
