{
  description = "sidequest flake";

  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable"; 
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.sidequestzip = {
    url = "https://github.com/SideQuestVR/SideQuest/releases/download/v0.10.33/SideQuest-0.10.33.tar.xz";
    flake = false;
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        version = "0.10.33";
        pname = "sidequest";
        pkgs = nixpkgs.legacyPackages."${system}";
        lib = pkgs.lib;
      in rec {
        defaultPackage = pkgs.stdenv.mkDerivation {
          inherit pname version;
          src = inputs.sidequestzip;
          dontUnpack = true;

          nativeBuildInputs = [
            pkgs.makeWrapper
            pkgs.wrapGAppsHook
          ];

          installPhase = ''
            mkdir -p "$out/lib" "$out/bin"
            cp -r "$src" "$out/lib/SideQuest"
            ln -s "$out/lib/SideQuest/sidequest" "$out/bin"
          '';

          postFixup = let
            libPath = lib.makeLibraryPath (with pkgs; [
              alsa-lib
              at-spi2-atk
              cairo
              cups
              dbus
              expat
              gdk-pixbuf
              glib
              gtk3
              mesa
              nss
              nspr
              libdrm
              xorg.libX11
              xorg.libxcb
              xorg.libXcomposite
              xorg.libXdamage
              xorg.libXext
              xorg.libXfixes
              xorg.libXrandr
              xorg.libxshmfence
              libxkbcommon
              xorg.libxkbfile
              pango
              stdenv.cc.cc.lib
              systemd
            ]);
          in ''
            patchelf \
              --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
              --set-rpath "${libPath}:$out/lib/SideQuest" \
              "$out/lib/SideQuest/sidequest"
          '';
        };
      }
    );
}

