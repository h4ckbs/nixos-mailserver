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

    mailserverModule = import ./.;

    # Generate a rst file describing options of the NixOS mailserver module 
    generateRstOptions = let
      eval = import (pkgs.path + "/nixos/lib/eval-config.nix") {
        inherit system;
        modules = [
          mailserverModule
          {
            mailserver.fqdn = "mx.example.com";
          }
        ];
        
      };
      options = pkgs.nixosOptionsDoc {
        options = eval.options;
      };
    in pkgs.runCommand "options.rst" { buildInputs = [pkgs.python3]; } ''
      echo Generating options.rst from ${options.optionsJSON}/share/doc/nixos/options.json
      python ${./scripts/generate-rst-options.py} ${options.optionsJSON}/share/doc/nixos/options.json > $out
    '';

    # This is a script helping users to generate this file in the docs directory
    generateRstOptionsScript = pkgs.writeScriptBin "generate-rst-options" ''
      cp -v ${generateRstOptions} ./docs/options.rst
    '';

    # This is to ensure we don't forget to update the options.rst file
    testRstOptions = pkgs.runCommand "test-rst-options" {} ''
      if ! diff -q ${./docs/options.rst} ${generateRstOptions}
      then
        echo "The file ./docs/options.rst is not up-to-date and needs to be regenerated!"
        echo "  hint: run 'nix-shell --run generate-rst-options' to generate this file"
      fi
      echo "test: ok" > $out
    '';

  in rec {
    nixosModules.mailserver = mailserverModule ;
    nixosModule = self.nixosModules.mailserver;
    hydraJobs.${system} = allTests // {
      test-rst-options = testRstOptions;
    };
    checks.${system} = allTests;
    devShell.${system} = pkgs.mkShell {
      buildInputs = with pkgs; [
        generateRstOptionsScript
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
