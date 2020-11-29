#  nixos-mailserver: a simple mail server
#  Copyright (C) 2016-2018  Robin Raymond
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>

{ pkgs ? import <nixpkgs> {}}:

let
  sendMail = pkgs.writeTextFile {
    "name" = "send-mail-to-send-only-account";
    "text" = ''
      EHLO mail.example.com
      MAIL FROM: none@example.com
      RCPT TO: send-only@example.com
      QUIT
    '';
  };

  hashPassword = password: pkgs.runCommand
    "password-${password}-hashed"
    { buildInputs = [ pkgs.apacheHttpd ]; } ''
      htpasswd -nbB "" "${password}" | cut -d: -f2 > $out
    '';

in
pkgs.nixosTest {
  name = "intern";
  nodes = {
    machine = { config, pkgs, ... }: {
      imports = [
        ./../default.nix
        ./lib/config.nix
      ];

      virtualisation.memorySize = 1024;

      mailserver = {
        enable = true;
        fqdn = "mail.example.com";
        domains = [ "example.com" ];

        loginAccounts = {
          "user1@example.com" = {
            hashedPassword = "$6$/z4n8AQl6K$kiOkBTWlZfBd7PvF5GsJ8PmPgdZsFGN1jPGZufxxr60PoR0oUsrvzm2oQiflyz5ir9fFJ.d/zKm/NgLXNUsNX/";
          };
          "send-only@example.com" = {
            hashedPasswordFile = hashPassword "send-only";
            sendOnly = true;
          };
        };

        vmailGroupName = "vmail";
        vmailUID = 5000;

        enableImap = false;
      };
    };
  };
  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    with subtest("vmail gid is set correctly"):
        machine.succeed("getent group vmail | grep 5000")

    with subtest("mail to send only accounts is rejected"):
        machine.wait_for_open_port(25)
        # TODO put this blocking into the systemd units
        machine.wait_until_succeeds(
            "timeout 1 ${pkgs.netcat}/bin/nc -U /run/rspamd/rspamd-milter.sock < /dev/null; [ $? -eq 124 ]"
        )
        machine.succeed(
            "cat ${sendMail} | ${pkgs.netcat-gnu}/bin/nc localhost 25 | grep -q 'This account cannot receive emails'"
        )

    with subtest("rspamd controller serves web ui"):
        machine.succeed(
            "${pkgs.curl}/bin/curl --unix-socket /run/rspamd/worker-controller.sock http://localhost/ | grep -q '<body>'"
        )

    with subtest("imap port 143 is closed and imaps is serving SSL"):
        machine.wait_for_closed_port(143)
        machine.wait_for_open_port(993)
        machine.succeed(
            "echo | ${pkgs.openssl}/bin/openssl s_client -connect localhost:993 | grep 'New, TLS'"
        )
  '';
}
