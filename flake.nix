{
  description = "A complete and Simple Nixos Mailserver";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "flake:nixpkgs/nixos-unstable";
  };

  outputs = { self, utils, nixpkgs }: {
    nixosModules.mailserver = import ./.;
    nixosModule = self.nixosModules.mailserver;
  } // utils.lib.eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShell = pkgs.mkShell {
      buildInputs = with pkgs; [
        (python3.withPackages (p: with p; [
          sphinx
          sphinx_rtd_theme
        ]))
        jq
        clamav
      ];
    };
  });
}
