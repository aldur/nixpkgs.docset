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

    inputs.nixpkgs.follows = "nixpkgs";
    inputs.nixpkgs-23-11.follows = "";
    inputs.nixpkgs-regression.follows = "";
    inputs.flake-compat.follows = "";
    inputs.flake-parts.follows = "";
    inputs.git-hooks-nix.follows = "";
  };

  inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nix-darwin = {
    url = "github:LnL7/nix-darwin";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixos-homepage = {
    url = "github:NixOS/nixos-homepage";
    flake = false; # We just need it to get the favicon
  };

  outputs =
    {
      nixpkgs,
      nix,
      nix-darwin,
      flake-utils,
      home-manager,
      nixos-homepage,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Version the favicon from the homepage repo, so we can manage it as a flake input.
        # Otherwise, fixed output derivation from the online favicon would continue to break.
        favicon = pkgs.stdenv.mkDerivation rec {
          name = "nix-favicon";
          version = nixos-homepage.rev;
          src = "${nixos-homepage}/core/public/logo/nixos-logomark-default-gradient-minimal.svg";

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

        nixpkgs-version = pkgs.lib.trivial.version;
        nixpkgs-docset = pkgs.stdenv.mkDerivation {
          pname = "nixpkgs-docset";
          version = nixpkgs-version;

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

        nixos-version = pkgs.lib.trivial.version;
        nixos-docset = pkgs.stdenv.mkDerivation {
          pname = "nixos-docset";
          version = nixos-version;

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
        nix-darwin-version = nix-darwin.rev;
        nix-darwin-docset = pkgs.stdenv.mkDerivation {
          pname = "nix-darwin-docset";
          version = nix-darwin-version;

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
        nix-version = nix-manual.version;
        nix-docset = pkgs.stdenv.mkDerivation {
          pname = "nix-docset";
          version = nix-version;

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

        home-manager-manual = home-manager.packages.${system}.docs-html;
        home-manager-version = (nixpkgs.lib.importJSON (home-manager + "/release.json")).release;
        home-manager-docset = pkgs.stdenv.mkDerivation {
          pname = "home-manager-docset";
          version = home-manager-version;

          src = pkgs.lib.fileset.toSource {
            root = ./.;
            fileset = ./home-manager.dashing.json;
          };

          buildInputs = [
            pkgs.dashing
          ];

          buildPhase = ''
            cp ${favicon}/favicon.png .
            cp -r "${home-manager-manual}/share/doc/home-manager/." .
            dashing build  --config ./home-manager.dashing.json .
          '';

          installPhase = ''
            mkdir -p $out/
            runHook preInstall
            cp -r home-manager.docset $out/
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
              home-manager-docset
            ];

            version = "${pkgs.lib.trivial.release}/${pkgs.lib.trivial.versionSuffix}";
          in
          rec {
            default = pkgs.symlinkJoin {
              name = "all nix docsets";
              paths = all;
            };

            all-tgz = pkgs.stdenv.mkDerivation {
              inherit version;
              pname = "all nix docsets targz";

              src = default;
              buildPhase =
                let
                  tar = "tar --dereference -czf";
                in
                ''
                  find . -maxdepth 1 -mindepth 1 -type d -name '*docset' -exec ${tar} {}.tgz {} \;
                  ${tar} all.tgz *.docset;
                '';

              installPhase = ''
                mkdir -p $out/
                runHook preInstall
                mv *.tgz $out/
                runHook postInstall
              '';
            };

            index = pkgs.stdenv.mkDerivation {
              inherit version;
              pname = "html index";

              src = all-tgz;

              buildPhase =
                let
                  template = pkgs.replaceVars ./index.html.template {
                    inherit
                      nix-version
                      nix-darwin-version
                      nixpkgs-version
                      home-manager-version
                      nixos-version
                      ;
                  };
                in
                ''
                  cp ${template} index.html
                '';

              installPhase = ''
                mkdir -p $out/
                runHook preInstall
                mv * $out/
                runHook postInstall
              '';
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
