{
  description = "Home Manager Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    #nur.url = "github:nix-community/NUR";
  };
  outputs =
    { self, home-manager, nixpkgs, flake-utils, nur, ... }:
    #flake-utils.lib.eachDefaultSystem (system:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        #overlays = [ nur.overlay ];
        config = {
          allowUnsupportedSystem = true;
          allowUnfree = true;
          allowBroken = true;
        };
      };
    in {
      homeConfigurations.zygot = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          #./modules/foot.nix
          #./modules/kakoune.nix
          #./modules/mpd.nix
          ./modules/neovim.nix
          ./modules/packages.nix
          #./modules/sway.nix
          ./home.nix
        ];
      };
      zygot = self.homeConfigurations.zygot.activationPackage;
      defaultPackage.${system} = self.zygot;
    };
}

