{
  description = "A flake for sriv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };

        buildToolchain = pkgs.rust-bin.nightly.latest.minimal.override {
          extensions = [ "rustc" "cargo" ];
        };

        rustPlatform = pkgs.makeRustPlatform {
          cargo = buildToolchain;
          rustc = buildToolchain;
        };

        # Runtime libraries specified in devenv.nix's enterShell
        runtimeLibs = with pkgs; [
          wayland
          libxkbcommon
          libGL
          vulkan-loader
        ];

        commonBuildArgs = {
          src = pkgs.lib.cleanSource ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
          nativeBuildInputs = [ 
            pkgs.pkg-config 
            pkgs.makeWrapper 
          ];
          buildInputs = [
            pkgs.openssl
            pkgs.libxkbcommon
            pkgs.libheif
            pkgs.fontconfig
          ] ++ runtimeLibs;
          doCheck = false;
        };

      in {
        packages = {
          sriv = rustPlatform.buildRustPackage (commonBuildArgs // {
            pname = "sriv";
            version = "0.1.0";

            postInstall = ''
              wrapProgram $out/bin/sriv \
                --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath runtimeLibs}"
            '';
          });

          default = pkgs.symlinkJoin {
            name = "sriv-workspace";
            paths = [
              self.packages.${system}.sriv
            ];
          };
        };
      });
}
