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
      ".local/state"

      # CACHE
      ".cache"

      #Stremio
      ".stremio-server"

      # APPs
      ".antigravity"
      ".gemini" 
      ".claude"
      ".bun"
      ".vscode"

      # FLATPAK
      # ".var/app"
      
    ];

users.lea.files = [
      ".gitconfig"
    ];
  };
}
