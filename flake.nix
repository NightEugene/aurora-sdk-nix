{
  description = "Aurora SDK flake for NixOS";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      pkgsFor = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
    in
    {
      packages = forAllSystems (system: {
        default = self.packages.${system}.aurora-sdk;
        aurora-sdk = (pkgsFor system).callPackage ./pkgs/aurora-sdk { };
      });

      overlays.default = final: _prev: {
        aurora-sdk = final.callPackage ./pkgs/aurora-sdk { };
      };

      homeModules.default = import ./modules/home/aurora-sdk.nix;

      devShells = forAllSystems (system: {
        default = (pkgsFor system).mkShellNoCC {
          packages = [ self.packages.${system}.aurora-sdk ];
        };
      });
    };
}
