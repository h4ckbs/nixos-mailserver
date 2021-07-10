{
  description = "A complete and Simple Nixos Mailserver";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "flake:nixpkgs/nixos-unstable";
    nixpkgs-21_05.url = "flake:nixpkgs/nixos-21.05";
    blobs = {
      url = "gitlab:simple-nixos-mailserver/blobs";
      flake = false;
    };
  };

  outputs = { self, utils, blobs, nixpkgs, nixpkgs-21_05 }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    # We want to test nixos-mailserver on several nixos releases
    releases = [
      {
        name = "unstable";
        pkgs = nixpkgs.legacyPackages.${system};
      }
      {
        name = "21_05";
        pkgs = nixpkgs-21_05.legacyPackages.${system};
      }
    ];
    testNames = [
      "internal"
      "external"
      "clamav"
      "multiple"
    ];
    genTest = testName: release: {
      "name"= "${testName}-${release.name}";
      "value"= import (./tests/. + "/${testName}.nix") {
        pkgs = release.pkgs;
        inherit blobs;
      };
    };
    # Generate an attribute set such as
    # {
    #   external-unstable = <derivation>;
    #   external-21_05 = <derivation>;
    #   ...
    # }
    allTests = pkgs.lib.listToAttrs (
      pkgs.lib.flatten (map (t: map (r: genTest t r) releases) testNames));

  in {
    nixosModules.mailserver = import ./.;
    nixosModule = self.nixosModules.mailserver;
    hydraJobs.${system} = allTests;
    checks.${system} = allTests;
    devShell.${system} = pkgs.mkShell {
      buildInputs = with pkgs; [
        (python3.withPackages (p: with p; [
          sphinx
          sphinx_rtd_theme
        ]))
        jq
        clamav
      ];
    };
  };
}
