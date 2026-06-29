{
  description = "Merge nix-templates with mine";
  outputs =
    { nix-templates, ... }@inputs:
    let
      lib = inputs.nixpkgs-lib.lib;
    in
    {
      # nix flake init -t github:msalmanrafadhlih/nix.templates#<template>
      templates = import ./templates.nix { inherit nix-templates; };

      # nix develop github:msalmanrafadhlih/nix.templates#<template> --impure
      devShells = lib.genAttrs lib.systems.flakeExposed (system: {
        flutter    = inputs.flutter-template.devShells.${system}.default;
        nodejs     = inputs.nodejs-template.devShells.${system}.default;
        rust-basic = inputs.rust-template.devShells.${system}.default;
        bun        = inputs.bun-template.devShells.${system}.default;
      });

      # inputs.<thisrepo>.devenvModules.<template>
      devenvModules = with inputs; {
        flutter     = flutter.devenvModules.default;
        nodejs      = nodejs.devenvModules.default;
        bun         = bun.devenvModules.default;
        rust-basic  = rust.devenvModules.default;
      };
    };

  inputs = {
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";

    # templates
    nix-templates.url = "github:nix-community/templates";

    rust.url    = "path:./rust";
    flutter.url = "path:./flutter";
    bun.url     = "path:./bun";
    nodejs.url  = "path:./nodejs";
  };
}
