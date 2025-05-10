{
  description = "Hakyll";

  inputs = {
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    haskellNix.url = "github:input-output-hk/haskell.nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system overlays;
          inherit (haskellNix) config;
        };
        flake = pkgs.hakyll.flake {
        };
        overlays = [ haskellNix.overlay
          (final: prev: {
            hakyll =
              final.haskell-nix.project' {
                src = ./.;
                compiler-nix-name = "ghc910";
                shell = {
                  tools = {
                    cabal = {};
                    haskell-language-server = {};
                  };
                  buildInputs = with pkgs; [
                    pkg-config
                  ];
                  withHoogle = true;
                };
              };
          })
        ];
      in flake // {
        packages.default = flake.packages."hakyll:lib:hakyll";
      });
}
