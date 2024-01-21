{ config, pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    settings = {
      folders = {
        "Documents" = {
          path = "/raidpool/encrypted/backups/syncthing/Documents";
          devices = [ "pixel7p" ];
        };
        "Camera" = {
          path = "/raidpool/encrypted/backups/syncthing/Documents";
          devices = [ "pixel7p" ];
        };
        "Download" = {
          path = "/raidpool/encrypted/backups/syncthing/Documents";
          devices = [ "pixel7p" ];
        };
        "DCIM" = {
          path = "/raidpool/encrypted/backups/syncthing/Documents";
          devices = [ "pixel7p" ];
        };
      };
      gui = {
        user = "patrick";
        password = "uhs3r4u8";
      };
    };
    guiAddress = "100.77.88.152:8384";
    user = "patrick";
    dataDir = "/raidpool/encrypted/backups/syncthing";
    configDir = "/raidpool/encrypted/backups/syncthing/config";
    overrideDevices = true;
    overrideFolders = true;
    settings.devices = {
      "pixel7p" = { id = "SJBAFVX-6SDD6GZ-5L4IQ7M-KXTHLZ6-JIHZYEX-V4PIW2C-PB7OBJZ-WR54OAX"; };
    };
  };
}
