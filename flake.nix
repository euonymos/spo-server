{
  description = "optim-server";
  nixConfig = {
    # We don't use Recursive Nix yet.
    extra-experimental-features = [ "nix-command" "flakes" "ca-derivations" "recursive-nix" ];
    extra-substituters = [ "https://cache.iog.io" "https://public-plutonomicon.cachix.org" "https://mlabs.cachix.org" ];
    extra-trusted-public-keys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" "public-plutonomicon.cachix.org-1:3AKJMhCLn32gri1drGuaZmFrmnue+KkKrhhubQk/CWc=" ];
    allow-import-from-derivation = "true";
    bash-prompt = "\\[\\e[0m\\][\\[\\e[0;2m\\]nix \\[\\e[0;1m\\]optim-server \\[\\e[0;93m\\]\\w\\[\\e[0m\\]]\\[\\e[0m\\]$ \\[\\e[0m\\]";
    cores = "1";
    max-jobs = "auto";
    auto-optimise-store = "true";
  };

  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    CHaP = {
      url = "github:input-output-hk/cardano-haskell-packages?ref=repo";
      flake = false;
    };

    # tooling.url = "github:mlabs-haskell/mlabs-tooling.nix";

    # ouroboros-network = {
    #   url = "github:input-output-hk/ouroboros-network";
    #   flake = false;
    # };

#    cardano-node = {
#      url = "github:input-output-hk/cardano-node?ref=erikd/ghc-9.2";
#      flake = false;
#    };

#    plutus = {
#      url = "github:input-output-hk/plutus?rev=867fd234301d28525404de839d9a3c8220cbea63";
#      flake = false;
#    };
#
#    cardano-ledger = {
#      url = "github:input-output-hk/cardano-ledger?rev=760a73e89ef040d3ad91b4b0386b3bbace9431a9";
#      flake = false;
#    };

  };

  outputs = { self, nixpkgs, flake-utils, haskellNix, CHaP }:
      flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
      let
        overlays = [ haskellNix.overlay
          (final: prev: {
            # This overlay adds our project to pkgs
            helloProject =
              final.haskell-nix.project' {
                src = ./.;
                compiler-nix-name = "ghc924";
                inputMap = { "https://input-output-hk.github.io/cardano-haskell-packages" = CHaP; };
                # This is used by `nix develop .` to open a shell for use with
                # `cabal`, `hlint` and `haskell-language-server`
                shell.tools = {
                  cabal = {};
                  hlint = {};
                  haskell-language-server = {};
                };
                # Non-Haskell shell tools go here
                shell.buildInputs = with pkgs; [
                  nixpkgs-fmt
                ];
                # This adds `js-unknown-ghcjs-cabal` to the shell.
                # shell.crossPlatforms = p: [p.ghcjs];
              };
          })
        ];
        pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
        flake = pkgs.helloProject.flake {
          # This adds support for `nix build .#js-unknown-ghcjs:hello:exe:hello`
          # crossPlatforms = p: [p.ghcjs];
        };
      in flake // {
        # Built by `nix build .`
        packages.default = flake.packages."hello:exe:hello";
      });


  # outputs = inputs@{ self, tooling, ... }: tooling.lib.mkFlake { inherit self; }
  #   {
  #     imports = [
  #       (tooling.lib.mkHaskellFlakeModule1 {
  #         project.src = ./.;
  #         project.extraHackage = [
  #           # "${inputs.ouroboros-network}/monoidal-synchronisation"
  #           # "${inputs.ouroboros-network}/network-mux"
  #           # "${inputs.ouroboros-network}/ouroboros-network"
  #           # "${inputs.ouroboros-network}/ouroboros-network-api"
  #           # "${inputs.ouroboros-network}/ouroboros-network-framework"
  #           # "${inputs.ouroboros-network}/ouroboros-network-mock"
  #           # "${inputs.ouroboros-network}/ouroboros-network-protocols"
  #           # "${inputs.ouroboros-network}/ouroboros-network-testing"
  #           # "${inputs.ouroboros-network}/ouroboros-consensus"
  #           # "${inputs.ouroboros-network}/ouroboros-consensus-byron"
  #           # "${inputs.ouroboros-network}/ouroboros-consensus-byron-test"
  #           # "${inputs.ouroboros-network}/ouroboros-consensus-byronspec"
  #           # "${inputs.ouroboros-network}/ouroboros-consensus-cardano"
  #           # "${inputs.ouroboros-network}/ouroboros-consensus-cardano-test"
  #           # "${inputs.ouroboros-network}/ouroboros-consensus-mock"
  #           # "${inputs.ouroboros-network}/ouroboros-consensus-mock-test"
  #           # "${inputs.ouroboros-network}/ouroboros-consensus-protocol"
  #           # "${inputs.ouroboros-network}/ouroboros-consensus-shelley"
  #           # "${inputs.ouroboros-network}/ouroboros-consensus-shelley-test"
  #           # "${inputs.ouroboros-network}/ouroboros-consensus-test"
  #           # "${inputs.ouroboros-network}/ouroboros-consensus-cardano-tools"
  #           # "${inputs.ouroboros-network}/ouroboros-consensus-diffusion"
  #           # "${inputs.ouroboros-network}/ntp-client"
  #           # "${inputs.ouroboros-network}/cardano-client"





  #         #  "${inputs.ouroboros-network}/ouroboros-consensus"
  #         #  "${inputs.ouroboros-network}/ouroboros-consensus-protocol"
  #         #  "${inputs.ouroboros-network}/ouroboros-consensus-cardano"
  #         #  "${inputs.ouroboros-network}/ouroboros-consensus-byron"
  #         #  "${inputs.ouroboros-network}/ouroboros-consensus-shelley"
  #         #  "${inputs.cardano-node}/cardano-api"
  #         #  "${inputs.cardano-ledger}/eras/alonzo/impl"
  #         #  "${inputs.cardano-ledger}/eras/alonzo/test-suite"
  #         #  "${inputs.cardano-ledger}/eras/babbage/impl"
  #         #  "${inputs.cardano-ledger}/eras/babbage/test-suite"
  #         #  "${inputs.cardano-ledger}/eras/conway/impl"
  #         #  "${inputs.cardano-ledger}/eras/conway/test-suite"
  #         #  "${inputs.cardano-ledger}/eras/shelley/impl"
  #         #  "${inputs.cardano-ledger}/eras/shelley/test-suite"
  #         #  "${inputs.cardano-ledger}/eras/shelley-ma/impl"
  #         #  "${inputs.cardano-ledger}/eras/shelley-ma/test-suite"
  #         #  "${inputs.cardano-ledger}/libs/cardano-protocol-tpraos"
  #         #  "${inputs.cardano-ledger}/libs/cardano-ledger-pretty"
  #         ];
  #       })
  #     ];
  #   };
}
