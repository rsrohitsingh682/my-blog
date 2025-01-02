{ stdenv, mdbook, mdbook-alerts, imagemagick, ... }:

stdenv.mkDerivation {
  name = "mdbook-site";
  src = ./.;

  buildInputs = [ imagemagick ];
  nativeBuildInputs = [ mdbook mdbook-alerts ];

  buildPhase = ''
    mdbook build
  '';

  installPhase = ''
    mkdir -p $out
    cp -r book/* $out/

  '';
}
