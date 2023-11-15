{ config, pkgs, ... }:

let 
  libedgetpu = config.boot.kernelPackages.callPackage ../../pkgs/libedgetpu {}; 
  gasket = config.boot.kernelPackages.callPackage ../../pkgs/gasket {};
in
{
  services.udev.packages = [ libedgetpu ];                                                                                                                                                                                              
  users.groups.plugdev = {};  
  boot.extraModulePackages = [ gasket ];
}
