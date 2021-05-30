{ nixpkgs, pulls, ... }:

let
  pkgs = import nixpkgs {};

  prs = builtins.fromJSON (builtins.readFile pulls);
  prJobsets =  pkgs.lib.mapAttrs (num: info:
    { enabled = 1;
      hidden = false;
      description = "PR ${num}: ${info.title}";
      nixexprinput = "snm";
      nixexprpath = ".hydra/default.nix";
      checkinterval = 30;
      schedulingshares = 20;
      enableemail = false;
      emailoverride = "";
      keepnr = 1;
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
          type = "git";
          value = "${info.target_repo_url} merge-requests/${info.iid}/head";
          emailresponsible = false;
        };
      };
    }
  ) prs;

  desc = prJobsets // {
    master = {
      description = "Build master branch of Simple NixOS MailServer";
      checkinterval = "60";
      enabled = "1";
      nixexprinput = "snm";
      nixexprpath = ".hydra/default.nix";
      schedulingshares = 100;
      enableemail = false;
      emailoverride = "";
      keepnr = 3;
      hidden = false;
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
          value = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver master";
          type = "git";
          emailresponsible = false;
        };
      };
    };
    "nixos-20.09" = {
      description = "Build the nixos-20.09 branch of Simple NixOS MailServer";
      checkinterval = "60";
      enabled = "1";
      nixexprinput = "snm";
      nixexprpath = ".hydra/default.nix";
      schedulingshares = 100;
      enableemail = false;
      emailoverride = "";
      keepnr = 3;
      hidden = false;
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
          value = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver nixos-20.09";
          type = "git";
          emailresponsible = false;
        };
      };
    };
  };

in {
  jobsets = pkgs.runCommand "spec-jobsets.json" {} ''
    cat >$out <<EOF
    ${builtins.toJSON desc}
    EOF
  '';
}
