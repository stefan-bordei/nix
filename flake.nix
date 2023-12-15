{
  description = "My nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowunfree = true;
        };	
      };
    in
    {
    nixosConfigurations.hivecluster = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit system; };
      modules = [
        ./machines/hivecluster/configuration.nix
      ];
    };
  };
}
