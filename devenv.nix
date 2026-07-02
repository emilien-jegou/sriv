{ pkgs, ... }:

{
  packages = [
pkgs.bacon 
  # deps
  pkgs.libxkbcommon
  pkgs.libheif pkgs.openssl pkgs.fontconfig ];

  languages.rust = {
    enable = true;
    channel = "nightly";
    components =[ "rustc" "cargo" "rust-src" "rustfmt" "rust-analyzer" "clippy" ];
    targets =[ "wasm32-unknown-unknown" "x86_64-unknown-linux-gnu" ];
  };

 enterShell = ''
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath (with pkgs; [
      wayland
      libxkbcommon
      libGL
      vulkan-loader
    ])}:$LD_LIBRARY_PATH
  '';

  dotenv.enable = true;
}
