{
  description = "Defold";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
	  let
	    system = "x86_64-linux";

	    pkgs = import nixpkgs {
		    inherit system;
	    };
	  in 
      {
        packages."${system}" = {
	        default = pkgs.stdenv.mkDerivation rec {
	          pname = "defold";
	          version = "1.9.8";

	          src = pkgs.fetchzip {
		          url = "https://github.com/defold/defold/releases/download/${version}/Defold-x86_64-linux.tar.gz";
		          hash = "sha256-KlQd4HzMHAp5HDSzX/3r3gsqbyW8dVBDmcWjewuf3mQ=";
	          };
            desktopSrc = ./.;

	          runtimeLibs = with pkgs; [
		          stdenv.cc.cc
		          alsa-lib
		          libGL
		          gtk3
		          glib
	          ] ++ (with pkgs.xorg; [
		          libX11
			        libXext
			        libXi
			        libXtst
			        libXrender
			        libXxf86vm
	          ]);

	          buildInputs = runtimeLibs;
	          nativeBuildInputs = with pkgs; [ autoPatchelfHook makeWrapper wrapGAppsHook libarchive ];

            postUnpack = ''
              pushd source
              bsdtar -xf packages/defold-f68db9583283029bd2c2425839119f34c253143b.jar --strip-components 2 icons/document.iconset
              popd
            '';

	          installPhase = ''
		          runHook preInstall
		          mkdir -p $out/opt
              mkdir -p $out/bin
		          cp -r ./ $out/opt/Defold/

              echo "#!/bin/sh" > $out/bin/Defold
              echo "cd $out/opt/Defold" >> $out/bin/Defold
              echo 'exec ./Defold "$@"' >> $out/bin/Defold
              chmod +x $out/bin/Defold

              wrapProgram $out/opt/Defold/Defold --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath runtimeLibs}"

              mkdir -p $out/share/applications/
              install -D $desktopSrc/Defold.desktop $out/share/applications/Defold.desktop
              install -Dm644 icon_16x16.png "$out/share/icons/hicolor/16x16/apps/defold.png"
              install -Dm644 icon_16x16@2x.png "$out/share/icons/hicolor/32x32/apps/defold.png"
              install -Dm644 icon_32x32@2x.png "$out/share/icons/hicolor/64x64/apps/defold.png"
              install -Dm644 icon_128x128.png "$out/share/icons/hicolor/128x128/apps/defold.png"
              install -Dm644 icon_256x256.png "$out/share/icons/hicolor/256x256/apps/defold.png"
              install -Dm644 icon_256x256@2x.png "$out/share/icons/hicolor/512x512/apps/defold.png"

		          substituteInPlace $out/share/applications/Defold.desktop --replace-fail "outpath" "$out/opt/Defold"
		          runHook postInstall
	          '';
	        };
        };
      };
}
