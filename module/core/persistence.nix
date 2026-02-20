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

      "/var/lib/docker" # Docker
"/etc/secureboot" #Lanzaboot
      "/var/lib/sbctl" # Lanzaboot
      "/var/lib/flatpak" # Flatpak
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
