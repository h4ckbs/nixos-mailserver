{ pkgs ? import <nixpkgs> {}
, ...
}:

let
  bindPassword = "unsafegibberish";
  alicePassword = "testalice";
  bobPassword = "testbob";
in
pkgs.nixosTest {
  name = "ldap";
  nodes = {
    machine = { config, pkgs, ... }: {
      imports = [
        ./../default.nix
        ./lib/config.nix
      ];

      virtualisation.memorySize = 1024;

      environment.systemPackages = [
        (pkgs.writeScriptBin "mail-check" ''
          ${pkgs.python3}/bin/python ${../scripts/mail-check.py} $@
        '')];

      services.openldap = {
        enable = true;
        settings = {
          children = {
            "cn=schema".includes = [
              "${pkgs.openldap}/etc/schema/core.ldif"
              "${pkgs.openldap}/etc/schema/cosine.ldif"
              "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
              "${pkgs.openldap}/etc/schema/nis.ldif"
            ];
            "olcDatabase={1}mdb" = {
              attrs = {
                objectClass = [
                  "olcDatabaseConfig"
                  "olcMdbConfig"
                ];
                olcDatabase = "{1}mdb";
                olcDbDirectory = "/var/lib/openldap";
                olcSuffix = "dc=example";
              };
            };
          };
        };
        declarativeContents."dc=example" = ''
          dn: dc=example
          objectClass: domain
          dc: example

          dn: cn=mail,dc=example
          objectClass: organizationalRole
          objectClass: simpleSecurityObject
          objectClass: top
          cn: mail
          userPassword: ${bindPassword}

          dn: ou=users,dc=example
          objectClass: organizationalUnit
          ou: users

          dn: cn=alice,ou=users,dc=example
          objectClass: inetOrgPerson
          cn: alice
          sn: Foo
          mail: alice@example.com
          userPassword: ${alicePassword}

          dn: cn=bob,ou=users,dc=example
          objectClass: inetOrgPerson
          cn: bob
          sn: Bar
          mail: bob@example.com
          userPassword: ${bobPassword}
        '';
      };

      mailserver = {
        enable = true;
        fqdn = "mail.example.com";
        domains = [ "example.com" ];
        localDnsResolver = false;

        ldap = {
          enable = true;
          uris = [
            "ldap://"
          ];
          bind = {
            dn = "cn=mail,dc=example";
            password = bindPassword;
          };
          searchBase = "ou=users,dc=example";
          searchScope = "sub";
        };

        vmailGroupName = "vmail";
        vmailUID = 5000;

        enableImap = false;
      };
    };
  };
  testScript = ''
    import sys

    from glob import glob

    machine.start()
    machine.wait_for_unit("multi-user.target")

    def test_lookup(map, key, expected):
      path = glob(f"/nix/store/*-{map}")[0]
      value = machine.succeed(f"postmap -q alice@example.com ldap:{path}").rstrip()
      try:
        assert value == expected
      except AssertionError:
        print(f"Expected {map} lookup for key '{key}' to return '{expected}, but got '{value}'", file=sys.stderr)
        raise


    with subtest("Test postmap lookups"):
      test_lookup("ldap-virtual-mailbox-map.cf", "alice@example.com", "alice")
      test_lookup("ldap-sender-login-map.cf", "alice", "alice")

      test_lookup("ldap-virtual-mailbox-map.cf", "bob@example.com", "alice")
      test_lookup("ldap-sender-login-map.cf", "bob", "alice")

    with subtest("Test doveadm lookups"):
      out = machine.succeed("doveadm user -u alice")
      machine.log(out)

      out = machine.succeed("doveadm user -u bob")
      machine.log(out)

    with subtest("Test account/mail address binding"):
      machine.fail(" ".join([
        "mail-check send-and-read",
        "--smtp-port 587",
        "--smtp-starttls",
        "--smtp-host localhost",
        "--smtp-username alice",
        "--imap-host localhost",
        "--imap-username bob",
        "--from-addr bob@example.com",
        "--to-addr aliceb@example.com",
        "--src-password-file <(echo '${alicePassword}')",
        "--dst-password-file <(echo '${bobPassword}')",
        "--ignore-dkim-spf"
      ]))
      machine.succeed("journalctl -u postfix | grep -q 'Sender address rejected: not owned by user alice'")

    with subtest("Test mail delivery"):
      machine.succeed(" ".join([
        "mail-check send-and-read",
        "--smtp-port 587",
        "--smtp-starttls",
        "--smtp-host localhost",
        "--smtp-username alice",
        "--imap-host localhost",
        "--imap-username bob",
        "--from-addr alice@example.com",
        "--to-addr bob@example.com",
        "--src-password-file <(echo '${alicePassword}')",
        "--dst-password-file <(echo '${bobPassword}')",
        "--ignore-dkim-spf"
      ]))
  '';
}
