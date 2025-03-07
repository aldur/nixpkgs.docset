{
  description = "Dash/Zeal docset from nixpkgs-manual and nixos-manual";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils = {
    url = "github:numtide/flake-utils";
    inputs.systems.follows = "systems";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
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
      in
      {
        packages.default = pkgs.symlinkJoin {
          name = "nix docsets";
          paths = [
            nixpkgs-docset
            nixos-docset
          ];
        };
      }
    );
}
