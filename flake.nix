# My Personal NixOS and Darwin System Flake Configuration.
#
# Based on Matthias Benaets config @ https://github.com/MatthiasBenaets/nixos-config

{
  description = "My Personal NixOS and Darwin System Flake Configuration";

 inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      darwin = {
        url = "github:lnl7/nix-darwin/master";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nur = {
        url = "github:nix-community/NUR";
      };

    };

  outputs = inputs @ { self, nixpkgs, home-manager, nur, darwin, ... }:
  let
      user = "billsb";
      location = "$HOME/.setup";
  in
  {
       nixosConfigurations = (
        # Imports ./hosts/default.nix
        import ./hosts {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs home-manager nur user location;
        }
      );
  };
}
