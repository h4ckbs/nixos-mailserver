{ nixpkgs, pulls, ... }:

let
  pkgs = import nixpkgs {};

  prs = builtins.fromJSON (builtins.readFile pulls);
  prJobsets =  pkgs.lib.mapAttrs (num: info:
    { enabled = 1;
      hidden = false;
      description = "PR ${num}: ${info.title}";
      checkinterval = 30;
      schedulingshares = 20;
      enableemail = false;
      emailoverride = "";
      keepnr = 1;
      type = 1;
      flake = "gitlab:simple-nixos-mailserver/nixos-mailserver/merge-requests/${info.iid}/head";
    }
  ) prs;
  # This could be removed once branch 20.09 and 21.05 would have been
  # removed.
  mkJobset = branch: {
    description = "Build ${branch} branch of Simple NixOS MailServer";
    checkinterval = "60";
    enabled = "1";
    schedulingshares = 100;
    enableemail = false;
    emailoverride = "";
    nixexprinput = "snm";
    nixexprpath = ".hydra/default.nix";
    type = 0;
    inputs = {
      # This is only used to allow Niv to use pkgs.fetchzip which is
      # required because of Hydra restricted evaluation mode.
      nixpkgs = {
        value = "https://github.com/NixOS/nixpkgs b6eefa48d8e10491e43c0c6155ac12b463f6fed3";
        type = "git";
        emailresponsible = false;
      };
      snm = {
        value = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver ${branch}";
        type = "git";
        emailresponsible = false;
      };
    };
    keepnr = 3;
    hidden = false;
  };
  mkFlakeJobset = branch: {
    description = "Build ${branch} branch of Simple NixOS MailServer";
    checkinterval = "60";
    enabled = "1";
    schedulingshares = 100;
    enableemail = false;
    emailoverride = "";
    keepnr = 3;
    hidden = false;
    type = 1;
    flake = "gitlab:simple-nixos-mailserver/nixos-mailserver/${branch}";
  };

  desc = prJobsets // {
    "master" = mkFlakeJobset "master";
    "nixos-21.05" = mkJobset "nixos-21.05";
    "nixos-21.11" = mkFlakeJobset "nixos-21.11";
  };

  log = {
    pulls = prs;
    jobsets = desc;
  };

in {
  jobsets = pkgs.runCommand "spec-jobsets.json" {} ''
    cat >$out <<EOF
    ${builtins.toJSON desc}
    EOF
    # This is to get nice .jobsets build logs on Hydra
    cat >tmp <<EOF
    ${builtins.toJSON log}
    EOF
    ${pkgs.jq}/bin/jq . tmp
  '';
}
