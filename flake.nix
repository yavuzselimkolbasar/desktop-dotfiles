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
    disko = {
      url                   = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, nix-cachyos-kernel, nix-flatpak, disko, ... }@inputs:
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
    # ── Installed system ──────────────────────────────────────────────────────
    nixosConfigurations.${hostConfig.hostname} = nixpkgs.lib.nixosSystem {
      system      = "x86_64-linux";
      specialArgs = { inherit inputs hostConfig; };
      modules     = [
        { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.default ]; }
        disko.nixosModules.disko
        ./modules/disko.nix
        ./modules/core.nix
        ./modules/desktop.nix
        ./modules/hardware.nix
        ./modules/kernel.nix
        ./modules/hardening.nix
        ./modules/security.nix
        ./modules/maintenance.nix
        lanzaboote.nixosModules.lanzaboote
      ] ++ homeModules;
    };

    # ── Live installer ISO ────────────────────────────────────────────────────
    # Build: nix build .#nixosConfigurations.iso.config.system.build.isoImage
    # Flash: dd if=result/iso/nixos-installer.iso of=/dev/sdX bs=4M status=progress
    # Boot USB → autologin as root → type: install
    nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
      system      = "x86_64-linux";
      specialArgs = { inherit inputs hostConfig; };
      modules     = [
        { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.default ]; }
        ./modules/core.nix
        ./modules/kernel.nix
        ./modules/iso.nix
      ];
    };
  };
}
