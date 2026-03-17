{
  inputs = {
    nixpkgs.url             = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url                   = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url         = "github:gmodena/nix-flatpak";
    lanzaboote = {
      url                   = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url  = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, nix-cachyos-kernel, nix-flatpak, ... }@inputs:
  let
    hostConfig = import ./host.nix;

    homeModules = [
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs    = true;
        home-manager.useUserPackages  = true;
        home-manager.users.${hostConfig.username} = import ./home/default.nix;
        home-manager.extraSpecialArgs = { inherit inputs hostConfig; };
        home-manager.sharedModules    = [ nix-flatpak.homeManagerModules.nix-flatpak ];
      }
    ];
  in
  {
    nixosConfigurations.${hostConfig.hostname} = nixpkgs.lib.nixosSystem {
      system      = "x86_64-linux";
      specialArgs = { inherit inputs hostConfig; };
      modules     = [
        { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.default ]; }
        ./modules/core.nix
        ./modules/desktop.nix
        ./modules/hardware.nix
        ./modules/kernel.nix
        ./modules/hardening.nix
        ./modules/security.nix
        ./modules/maintenance.nix
        ./modules/performance.nix
        lanzaboote.nixosModules.lanzaboote
      ] ++ homeModules;
    };
  };
}
