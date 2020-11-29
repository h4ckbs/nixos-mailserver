Quick Start
===========

.. code:: nix

   { config, pkgs, ... }:
   let release = "nixos-20.09";
   in {
     imports = [
       (builtins.fetchTarball {
         url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz";
         # This hash needs to be updated
         sha256 = "0000000000000000000000000000000000000000000000000000";
       })
     ];

     mailserver = {
       enable = true;
       fqdn = "mail.example.com";
       domains = [ "example.com" "example2.com" ];
       loginAccounts = {
           "user1@example.com" = {
               # nix run nixpkgs.apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2 > /hashed/password/file/location
               hashedPasswordFile = "/hashed/password/file/location";

               aliases = [
                   "info@example.com"
                   "postmaster@example.com"
                   "postmaster@example2.com"
               ];
           };
       };
     };
   }
