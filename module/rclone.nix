{ pkgs, config, ... }:

let
  cacheMaxSize = "800G";
  cacheMinFree = "50G";
  remoteName = "onedrive";
  mountPath = "/home/LEA/OneDrive";
in
{
  environment.systemPackages = [
    pkgs.rclone
    pkgs.fuse3
  ];

  # Allow non-root users to use FUSE
  programs.fuse.userAllowOther = true;

  # Define the systemd user service
  systemd.user.services.rclone-onedrive = {
    description = "Rclone OneDrive Mount";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "default.target" ];

    serviceConfig = {
      Type = "notify";
      # Use the system wrapper for fusermount3 to ensure proper permissions
      Environment = "PATH=/run/wrappers/bin:$PATH";

      ExecStartPre = [
        # 1. Unmount if something is already there (lazy unmount)
        "-/run/wrappers/bin/fusermount3 -uz ${mountPath}"
        # 2. Force remove the directory to clear stale metadata from the old persistence setup
        "-${pkgs.coreutils}/bin/rm -rf ${mountPath}"
        # 3. Create a clean, fresh mount point
        "${pkgs.coreutils}/bin/mkdir -p ${mountPath}"
      ];

      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount ${remoteName}: ${mountPath} \
          --vfs-cache-mode full \
          --vfs-cache-max-age 9999h \
          --vfs-cache-max-size ${cacheMaxSize} \
          --vfs-cache-min-free-space ${cacheMinFree} \
          --dir-cache-time 9999h \
          --poll-interval 15s \
          --log-level INFO \
          --log-file /home/LEA/.rclone-onedrive.log \
          --allow-other
      '';

      ExecStop = "/run/wrappers/bin/fusermount3 -uz ${mountPath}";
      Restart = "on-failure";
      RestartSec = "15"; # Reduced wait time for quicker recovery
    };
  };

  # Ensure the user service starts on boot
  users.users.LEA.linger = true;
}
