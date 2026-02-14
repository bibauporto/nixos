{ config, pkgs, lib, ... }:
{
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/sbctl"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
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
      ".cache/rclone"
      ".cache/nvim"
      #################      

      ################
      # APPs
      ".antigravity"
      ".gemini"
      ".bun"
      ".vscode"
       ###############


      
      ".gnupg"
    ];
  };
}
