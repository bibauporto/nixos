{ pkgs, config, ... }:

let
  cacheMaxSize = "800G";
  cacheMinFree = "50G";
  remoteName = "onedrive";
  mountPath = "/home/LEA/OneDrive";
in
{
  environment.systemPackages = [ pkgs.rclone pkgs.fuse3 ];

  # Allow non-root users to use FUSE (needed for mounting)
  programs.fuse.userAllowOther = true;

  # Define the systemd user service
  systemd.user.services.rclone-onedrive = {
    description = "Rclone OneDrive Mount";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "default.target" ];

    serviceConfig = {
      Type = "notify";
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p ${mountPath}"
        "-${pkgs.fuse3}/bin/fusermount3 -u ${mountPath}"
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
          --log-file /home/LEA/.rclone-onedrive.log
      '';
      ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u ${mountPath}";
      Restart = "on-failure";
      RestartSec = "30";
    };
  };

  # Enable lingering so the mount starts even if you haven't logged in yet
  users.users.LEA.linger = true;
}