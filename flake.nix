{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    crane.url = "github:ipetkov/crane";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        {
          pkgs,
          lib,
          system,
          ...
        }:
        let
          rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
          craneLib = (inputs.crane.mkLib pkgs).overrideToolchain rust;
          overlays = [ inputs.rust-overlay.overlays.default ];

          # Sources for Nix Derivations
          src = ./.;
          buildInputs = [ ];
          nativeBuildInputs = [
            # Build tools
            rust

            # Qemu
            pkgs.qemu

            # NuShell
            pkgs.nushell
          ];

          # Nix Derivations (Nix flake's outputs)
          test-baremetal-rust = craneLib.buildPackage {
            inherit src buildInputs nativeBuildInputs;

            strictDeps = true;
            doCheck = false;
            cargoArtifacts = null;
          };
          cargo-clippy = craneLib.cargoClippy {
            inherit src buildInputs nativeBuildInputs;
          };
          cargo-doc = craneLib.cargoDoc {
            inherit src buildInputs nativeBuildInputs;
          };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system overlays;
          };

          treefmt = {
            projectRootFile = ".git/config";

            # Nix
            programs.nixfmt.enable = true;

            # Rust
            programs.rustfmt.enable = true;
            settings.formatter.rustfmt.command = "${rust}/bin/rustfmt";

            # TOML
            programs.taplo.enable = true;

            # GitHub Actions
            programs.actionlint.enable = true;

            # Markdown
            programs.mdformat.enable = true;

            # ShellScript
            programs.shellcheck.enable = true;
            programs.shfmt.enable = true;
          };

          packages = {
            inherit test-baremetal-rust;
            default = test-baremetal-rust;
            doc = cargo-doc;
          };

          checks = {
            inherit test-baremetal-rust cargo-clippy cargo-doc;
          };

          devShells.default = pkgs.mkShell {
            inherit buildInputs nativeBuildInputs;
          };
        };
    };
}
