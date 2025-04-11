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
	          nativeBuildInputs = with pkgs; [ autoPatchelfHook makeWrapper wrapGAppsHook ];

	          installPhase = ''
		          runHook preInstall
		          mkdir -p $out/opt
		          mkdir -p $out/bin
		          cp -r ./ $out/opt/Defold/
		          wrapProgram $out/opt/Defold/Defold --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath runtimeLibs}"
		          ln -s $out/opt/Defold/Defold $out/bin
		          runHook postInstall
	          '';
	        };
        };
      };
}
