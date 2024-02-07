{ config, pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    settings = {
      folders = {
        "Documents" = {
          path = "/raidpool/encrypted/backups/syncthing/Documents";
          devices = [ "pixel7p" ];
          id = "Documents";
        };
        "Download" = {
          path = "/raidpool/encrypted/backups/syncthing/Download";
          devices = [ "pixel7p" ];
          id = "1ns25-z5je0";
        };
        "DCIM" = {
          path = "/raidpool/encrypted/backups/syncthing/DCIM";
          devices = [ "pixel7p" ];
          id = "DCIM";
        };
        "Movies" = {
          path = "/raidpool/encrypted/backups/syncthing/Movies";
          devices = [ "pixel7p" ];
          id = "9vo9m-0io9y";
        };
        "App Pictures" = {
          path = "/raidpool/encrypted/backups/syncthing/App_Pictures";
          devices = [ "pixel7p" ];
          id = "3gawa-iwg77";
        };
      };
    };

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
