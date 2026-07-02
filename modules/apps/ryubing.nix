{ ... }: {
  flake.modules.darwin.ryubing = { pkgs, self, ... }: {
    nixpkgs.overlays = [
      (final: _: {
        ryubing = final.callPackage "${self}/pkgs/ryubing.nix" {};
      })
    ];

    environment.systemPackages = [ pkgs.ryubing ];
  };
}
