{
  description = "Dash/Zeal docset for nix-manual, nixpkgs-manual, and nixos-manual";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };

  inputs.nix = {
    url = "github:NixOS/nix";

    # inputs.nixpkgs.follows = "nixpkgs";
    inputs.nixpkgs-23-11.follows = "";
    inputs.nixpkgs-regression.follows = "";
    inputs.flake-compat.follows = "";
    inputs.flake-parts.follows = "";
    inputs.git-hooks-nix.follows = "";
  };

  inputs.nix-darwin = {
    url = "github:LnL7/nix-darwin";
  };

  outputs =
    {
      nixpkgs,
      nix,
      nix-darwin,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        favicon = pkgs.stdenv.mkDerivation rec {
          name = "nix-favicon";
          version = "2025-02-27";

          src = pkgs.fetchurl {
            url = "https://nixos.org/favicon.ico";
            hash = "sha256-cJjvgyuApfVDESJ3jol2U3UR9ntKgxzJx/DJu/+YZIk=";
          };

          dontUnpack = true;
          buildInputs = [
            pkgs.imagemagick
          ];

          buildPhase = ''
            magick "${src}" -thumbnail 32x32 -alpha on -background none -flatten "favicon.png"
          '';

          installPhase = ''
            mkdir -p $out/
            runHook preInstall
            install -Dm755 favicon.png -t $out/
            runHook postInstall
          '';
        };

        nixpkgs-docset = pkgs.stdenv.mkDerivation {
          pname = "nixpkgs-docset";
          version = pkgs.lib.trivial.version;

          src = pkgs.lib.fileset.toSource {
            root = ./.;
            fileset = ./nixpkgs.dashing.json;
          };

          buildInputs = [
            pkgs.dashing
          ];

          buildPhase = ''
            cp ${favicon}/favicon.png .
            cp -r "${pkgs.nixpkgs-manual}/share/doc/nixpkgs/." .
            mv manual.html index.html
            rm nixpkgs-manual.epub
            dashing build --config ./nixpkgs.dashing.json .
            rm nixpkgs.docset/Contents/Resources/Documents/favicon.png
          '';

          installPhase = ''
            mkdir -p $out/
            runHook preInstall
            cp -r nixpkgs.docset $out/
            runHook postInstall
          '';
        };

        nixos-manual =
          # NOTE: We kinda hack it here by forcing it to support any `system` (including macOS)
          # Because of lazy evaluation, this works.
          (import (nixpkgs + "/nixos/release.nix") { supportedSystems = [ system ]; }).manualHTML.${system};

        nixos-docset = pkgs.stdenv.mkDerivation {
          pname = "nixos-docset";
          version = pkgs.lib.trivial.version;

          src = pkgs.lib.fileset.toSource {
            root = ./.;
            fileset = ./nixos.dashing.json;
          };

          buildInputs = [
            pkgs.dashing
          ];

          buildPhase = ''
            cp ${favicon}/favicon.png .
            cp -r "${nixos-manual}/share/doc/nixos/." .
            dashing build  --config ./nixos.dashing.json .
            rm nixos.docset/Contents/Resources/Documents/favicon.png
          '';

          installPhase = ''
            mkdir -p $out/
            runHook preInstall
            cp -r nixos.docset $out/
            runHook postInstall
          '';
        };

        nix-darwin-manual = nix-darwin.packages.${system}.manualHTML;
        nix-darwin-docset = pkgs.stdenv.mkDerivation {
          pname = "nix-darwin-docset";
          version = nix-darwin.rev;

          src = pkgs.lib.fileset.toSource {
            root = ./.;
            fileset = ./nix-darwin.dashing.json;
          };

          buildInputs = [
            pkgs.dashing
          ];

          buildPhase = ''
            cp ${favicon}/favicon.png .
            cp -r "${nix-darwin-manual}/share/doc/darwin/." .
            dashing build  --config ./nix-darwin.dashing.json .
            rm nix-darwin.docset/Contents/Resources/Documents/favicon.png
          '';

          installPhase = ''
            mkdir -p $out/
            runHook preInstall
            cp -r nix-darwin.docset $out/
            runHook postInstall
          '';
        };

        nix-manual = nix.packages.${system}.nix-manual;
        nix-docset = pkgs.stdenv.mkDerivation {
          pname = "nix-docset";
          version = nix-manual.version;

          src = pkgs.lib.fileset.toSource {
            root = ./.;
            fileset = ./nix.dashing.json;
          };

          buildInputs = [
            pkgs.dashing
          ];

          buildPhase = ''
            cp -r "${nix-manual}/share/doc/nix/manual/." .
            rm print.html
            dashing build  --config ./nix.dashing.json .
            rm nix.docset/Contents/Resources/Documents/favicon.svg
          '';

          installPhase = ''
            mkdir -p $out/
            runHook preInstall
            cp -r nix.docset $out/
            runHook postInstall
          '';
        };
      in
      {
        packages =
          let
            all = [
              nixpkgs-docset
              nixos-docset
              nix-docset
              nix-darwin-docset
            ];
          in
          {
            default = pkgs.symlinkJoin {
              name = "nix docsets";
              paths = all;
            };
          }
          // builtins.listToAttrs (
            map (value: {
              name = value.pname;
              inherit value;
            }) all
          );
      }
    );
}
