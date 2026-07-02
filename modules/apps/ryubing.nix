{ ... }: {
  flake.modules.darwin.ryubing = { pkgs, ... }: {
    nixpkgs.overlays = [
      (final: _: {
        ryubing = final.callPackage ../../../pkgs/ryubing.nix {};
      })
    ];

    environment.systemPackages = [ pkgs.ryubing ];
  };
}
