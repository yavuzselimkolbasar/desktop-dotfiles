{ config, pkgs, hostConfig, ... }:

{
  imports = [
    ./packages.nix
    ./gnome.nix
  ];

  home.username      = hostConfig.username;
  home.homeDirectory = "/home/${hostConfig.username}";
  home.stateVersion  = "25.11";
}
