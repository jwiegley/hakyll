{
  description = "Hakyll - A static website compiler library";

  inputs = {
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    haskellNix.url = "github:input-output-hk/haskell.nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ haskellNix.overlay
          (final: prev: {
            hakyll =
              final.haskell-nix.project' {
                src = ./.;
                # GHC 9.6.6 provides better ecosystem compatibility
                # while still satisfying all hakyll.cabal constraints
                compiler-nix-name = "ghc966";

                # Cabal configuration
                # haskell.nix automatically detects hakyll.cabal

                shell = {
                  # Development tools
                  tools = {
                    cabal = {};
                    haskell-language-server = {};
                    hlint = {};
                    fourmolu = {};
                  };

                  # System dependencies
                  buildInputs = with pkgs; [
                    pkg-config
                    zlib
                  ];

                  # Enable Hoogle documentation
                  withHoogle = true;

                  # Helpful shell message
                  shellHook = ''
                    echo "Hakyll development environment"
                    echo "  GHC: $(ghc --version)"
                    echo "  Cabal: $(cabal --version | head -1)"
                    echo ""
                    echo "Quick start:"
                    echo "  cabal build          # Build the library"
                    echo "  cabal test           # Run tests"
                    echo "  cabal repl           # Start REPL"
                  '';
                };
              };
          })
        ];

        pkgs = import nixpkgs {
          inherit system overlays;
          inherit (haskellNix) config;
        };

        flake = pkgs.hakyll.flake {};

      in flake // {
        # Default package is the library
        packages.default = flake.packages."hakyll:lib:hakyll";

        # Also expose executables
        packages.hakyll-init = flake.packages."hakyll:exe:hakyll-init";

        # Default app runs hakyll-init
        apps.default = {
          type = "app";
          program = "${flake.packages."hakyll:exe:hakyll-init"}/bin/hakyll-init";
        };
      });
}
