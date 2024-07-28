{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        let

          buildInputs = with pkgs; [
            dbus
            gdk-pixbuf
            glib
            graphene
            gtk4
            pango
          ];

          nativeBuildInputs = with pkgs; [
            meson
            # ninja
            pkg-config
            wrapGAppsHook4
            rustPlatform.cargoSetupHook
          ];

          bookshelf = pkgs.callPackage (
            { rustPlatform }:
            rustPlatform.buildRustPackage {
              pname = "bookshelf";
              version = "unstable";
              src = ./.;

              cargoHash = "sha256-n26J4YBtbpD8YkgVeC78dz0m0bAJH9hjox5sY+cvbKY=";

              inherit buildInputs nativeBuildInputs;
            }
          ) { };
        in
        {
          packages.default = bookshelf;
        };
    };
}
