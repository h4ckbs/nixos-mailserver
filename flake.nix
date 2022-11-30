{
  description = "A complete and Simple Nixos Mailserver";

  inputs = {
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "flake:nixpkgs/nixos-unstable";
    nixpkgs-22_11.url = "flake:nixpkgs/nixos-22.11";
    blobs = {
      url = "gitlab:simple-nixos-mailserver/blobs";
      flake = false;
    };
  };

  outputs = { self, utils, blobs, nixpkgs, nixpkgs-22_11, ... }: let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    releases = [
      {
        name = "unstable";
        pkgs = nixpkgs.legacyPackages.${system};
      }
      {
        name = "22.11";
        pkgs = nixpkgs-22_11.legacyPackages.${system};
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
    allTests = lib.listToAttrs (
      lib.flatten (map (t: map (r: genTest t r) releases) testNames));

    mailserverModule = import ./.;

    # Generate a MarkDown file describing the options of the NixOS mailserver module
    optionsDoc = let
      eval = lib.evalModules {
        modules = [
          mailserverModule
          {
            _module.check = false;
            mailserver = {
              fqdn = "mx.example.com";
              domains = [
                "example.com"
              ];
              dmarcReporting = {
                organizationName = "Example Corp";
                domain = "example.com";
              };
            };
          }
        ];
      };
      options = builtins.toFile "options.json" (builtins.toJSON
        (lib.filter (opt: opt.visible && !opt.internal && lib.head opt.loc == "mailserver")
          (lib.optionAttrSetToDocList eval.options)));
    in pkgs.runCommand "options.md" { buildInputs = [pkgs.python3Minimal]; } ''
      echo "Generating options.md from ${options}"
      python ${./scripts/generate-options.py} ${options} > $out
    '';

    # This is a script helping users to generate this file in the docs directory
    generateOptions = pkgs.writeShellScriptBin "generate-options" ''
      install -vm644 ${optionsDoc} ./docs/options.md
    '';

    # This is to ensure we don't forget to update the options.md file
    testOptions = pkgs.runCommand "test-options" {} ''
      if ! diff -q ${./docs/options.md} ${optionsDoc}
      then
        echo "The file ./docs/options.md is not up-to-date and needs to be regenerated!"
        echo "  hint: run 'nix-shell --run generate-options' to generate this file"
        exit 1
      fi
      echo "test: ok" > $out
    '';

    documentation = pkgs.stdenv.mkDerivation {
      name = "documentation";
      src = lib.sourceByRegex ./docs ["logo\\.png" "conf\\.py" "Makefile" ".*\\.rst"];
      buildInputs = [(
        pkgs.python3.withPackages (p: with p; [
          sphinx
          sphinx_rtd_theme
          myst-parser
        ])
      )];
      buildPhase = ''
        cp ${optionsDoc} options.md
        # Workaround for https://github.com/sphinx-doc/sphinx/issues/3451
        unset SOURCE_DATE_EPOCH
        make html
      '';
      installPhase = ''
        cp -Tr _build/html $out
      '';
    };

  in {
    nixosModules = rec {
      mailserver = mailserverModule;
      default = mailserver;
    };
    nixosModule = self.nixosModules.default; # compatibility
    hydraJobs.${system} = allTests // {
      test-options = testOptions;
      inherit documentation;
    };
    checks.${system} = allTests;
    devShells.${system}.default = pkgs.mkShell {
      inputsFrom = [ documentation ];
      packages = with pkgs; [
        generateOptions
        clamav
      ];
    };
    devShell.${system} = self.devShells.${system}.default; # compatibility
  };
}
