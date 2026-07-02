{
  description = "Fully Dendritic nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    comfyui-nix.url = "github:utensils/comfyui-nix";
  };

  outputs = inputs@{ self, flake-parts, nixpkgs, ... }:
    let
      collectNixFiles = dir:
        let
          contents = builtins.readDir dir;
        in
          builtins.concatLists (builtins.attrValues (
            builtins.mapAttrs (name: type:
              if type == "directory"
              then collectNixFiles (dir + "/${name}")
              else if type == "regular" && nixpkgs.lib.hasSuffix ".nix" name
              then [ (dir + "/${name}") ]
              else []
            ) contents
          ));
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
      ] ++ collectNixFiles ./modules;
    };
}
