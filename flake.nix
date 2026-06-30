{
  description = "Fully Dendritic nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, flake-parts, nix-darwin, nixpkgs, ... }:
    let
      # Automatically reads the modules directory and generates an import list
      autoModules = let
        dirContents = builtins.readDir ./modules;
        validFiles = nixpkgs.lib.filterAttrs (name: type:
          (type == "regular" || type == "symlink") &&
          nixpkgs.lib.hasSuffix ".nix" name &&
          name != "hosts.nix" # Exclude the host definition tracker itself
        ) dirContents;
      in
        map (name: ./modules + "/${name}") (builtins.attrNames validFiles);
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
        ./modules/hosts.nix # Statically import our machine composition file
      ] ++ autoModules;      # Dynamically import all other feature modules
    };
}
