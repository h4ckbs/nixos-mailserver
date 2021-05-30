# Generate an attribute sets containing all tests for all releaeses
# It looks like:
# - external.nixpkgs_20.03
# - external.nixpkgs_unstable
# - internal.nixpkgs_20.03
# - internal.nixpkgs_unstable

with builtins;

let
  sources = import ../nix/sources.nix;

  releases = listToAttrs (map genRelease releaseNames);

  genRelease = name: {
    name = name;
    value = import sources."${name}" {};
  };

  genTest = testName: release:
  let
    pkgs = releases."${release}";
    test = pkgs.callPackage (./. + "/${testName}.nix") { };
  in {
    "name"= builtins.replaceStrings ["." "-"] ["_" "_"] release;
    "value"= test;
  };

  releaseNames = [
    "nixpkgs-unstable"
    "nixpkgs-20.09"
    "nixpkgs-21.05"
  ];

  testNames = [
    "internal"
    "external"
    "clamav"
    "multiple"
  ];

  # Generate an attribute set containing one test per releases
  genTests = testName: {
    name = testName;
    value = listToAttrs (map (genTest testName) (builtins.attrNames releases));
  };
  
in listToAttrs (map genTests testNames)
