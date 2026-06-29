{
  description = "Rust Development Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    devenv.url = "github:cachix/devenv";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      fenix,
      naersk,
      flake-utils,
      devenv,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        # Toolchain juga didefinisikan di sini untuk naersk
        toolchain = fenix.packages.${system}.combine [
          fenix.packages.${system}.stable.cargo
          fenix.packages.${system}.stable.rustc
          fenix.packages.${system}.stable.rust-src
          fenix.packages.${system}.stable.rust-analyzer
          fenix.packages.${system}.stable.clippy
          fenix.packages.${system}.stable.rustfmt
        ];

        naerskLib = pkgs.callPackage naersk {
          cargo = toolchain;
          rustc = toolchain;
        };
      in
      {
        devShells.default     = import ./devenv.nix {inherit pkgs inputs toolchain;};
        devenvModules.default = import ./devenv.nix { inherit toolchain; };

        # Build project sebagai paket Nix
        packages.default = naerskLib.buildPackage {
          src = ./.;
        };
      }
    );
}
