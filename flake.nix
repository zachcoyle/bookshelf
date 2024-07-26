{
  description = "";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devshell.flakeModule ];
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
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
            # vulkan-loader # iced
            wayland
            wayland-protocols
            libxkbcommon
          ];

          nativeBuildInputs = with pkgs; [
            pkg-config
            # gtk-layer-shell # iced
            gtk4
          ];

          bookshelf = inputs.crane.lib.${pkgs.system}.buildPackage {
            src = ./.;
            inherit buildInputs nativeBuildInputs;
          };

        in
        {

          packages.default = bookshelf;

          devshells.default = {
            name = "bookshelf";
            env = [ ];
            packages = with pkgs; [
              cargo
              rustc
            ];
          };
        };
    };
}
