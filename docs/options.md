
# Mailserver options

## `mailserver`



`````{option} mailserver.debug
Whether to enable verbose logging for mailserver related services. This
intended be used for development purposes only, you probably don't want
to enable this unless you're hacking on nixos-mailserver.


- type: ```boolean```
- default: ```False```

`````


`````{option} mailserver.domains
The domains that this mail server serves.

- type: ```list of string```
- default: ```[]```
- example: ```['example.com']```
`````


`````{option} mailserver.enable
Whether to enable nixos-mailserver.

- type: ```boolean```
- default: ```False```
- example: ```True```
`````


`````{option} mailserver.enableImap
Whether to enable IMAP with STARTTLS on port 143.


- type: ```boolean```
- default: ```True```

`````


`````{option} mailserver.enableImapSsl
Whether to enable IMAP with TLS in wrapper-mode on port 993.


- type: ```boolean```
- default: ```True```

`````


`````{option} mailserver.enableManageSieve
Whether to enable ManageSieve, setting this option to true will open
port 4190 in the firewall.

The ManageSieve protocol allows users to manage their Sieve scripts on
a remote server with a supported client, including Thunderbird.


- type: ```boolean```
- default: ```False```

`````


`````{option} mailserver.enablePop3
Whether to enable POP3 with STARTTLS on port on port 110.


- type: ```boolean```
- default: ```False```

`````


`````{option} mailserver.enablePop3Ssl
Whether to enable POP3 with TLS in wrapper-mode on port 995.


- type: ```boolean```
- default: ```False```

`````


`````{option} mailserver.enableSubmission
Whether to enable SMTP with STARTTLS on port 587.


- type: ```boolean```
- default: ```True```

`````


`````{option} mailserver.enableSubmissionSsl
Whether to enable SMTP with TLS in wrapper-mode on port 465.


- type: ```boolean```
- default: ```True```

`````


`````{option} mailserver.extraVirtualAliases
Virtual Aliases. A virtual alias `"info@example.com" = "user1@example.com"` means that
all mail to `info@example.com` is forwarded to `user1@example.com`. Note
that it is expected that `postmaster@example.com` and `abuse@example.com` is
forwarded to some valid email address. (Alternatively you can create login
accounts for `postmaster` and (or) `abuse`). Furthermore, it also allows
the user `user1@example.com` to send emails as `info@example.com`.
It's also possible to create an alias for multiple accounts. In this
example all mails for `multi@example.com` will be forwarded to both
`user1@example.com` and `user2@example.com`.


- type: ```attribute set of ((Login Account) or non-empty (list of (Login Account)))```
- default: ```{}```
- example: ```{'abuse@example.com': 'user1@example.com', 'info@example.com': 'user1@example.com', 'multi@example.com': ['user1@example.com', 'user2@example.com'], 'postmaster@example.com': 'user1@example.com'}```
`````


`````{option} mailserver.forwards
To forward mails to an external address. For instance,
the value {`"user@example.com" = "user@elsewhere.com";}`
means that mails to `user@example.com` are forwarded to
`user@elsewhere.com`. The difference with the
{option}`mailserver.extraVirtualAliases` option is that `user@elsewhere.com`
can't send mail as `user@example.com`. Also, this option
allows to forward mails to external addresses.


- type: ```attribute set of ((list of string) or string)```
- default: ```{}```
- example: ```{'user@example.com': 'user@elsewhere.com'}```
`````


`````{option} mailserver.fqdn
The fully qualified domain name of the mail server.

- type: ```string```

- example: ```mx.example.com```
`````


`````{option} mailserver.hierarchySeparator
The hierarchy separator for mailboxes used by dovecot for the namespace 'inbox'.
Dovecot defaults to "." but recommends "/".
This affects how mailboxes appear to mail clients and sieve scripts.
For instance when using "." then in a sieve script "example.com" would refer to the mailbox "com" in the parent mailbox "example".
This does not determine the way your mails are stored on disk.
See https://wiki.dovecot.org/Namespaces for details.


- type: ```string```
- default: ```.```

`````


`````{option} mailserver.indexDir
Folder to store search indices. If null, indices are stored
along with email, which could not necessarily be desirable,
especially when {option}`mailserver.fullTextSearch.enable` is `true` since
indices it creates are voluminous and do not need to be backed
up.

Be careful when changing this option value since all indices
would be recreated at the new location (and clients would need
to resynchronize).

Note the some variables can be used in the file path. See
https://doc.dovecot.org/configuration_manual/mail_location/#variables
for details.


- type: ```null or string```
- default: ```None```
- example: ```/var/lib/dovecot/indices```
`````


`````{option} mailserver.keyFile
Scheme 1)
Location of the key file


- type: ```path```

- example: ```/root/mail-server.key```
`````


`````{option} mailserver.lmtpSaveToDetailMailbox
If an email address is delimited by a "+", should it be filed into a
mailbox matching the string after the "+"?  For example,
user1+test@example.com would be filed into the mailbox "test".


- type: ```one of "yes", "no"```
- default: ```yes```

`````


`````{option} mailserver.localDnsResolver
Runs a local DNS resolver (kresd) as recommended when running rspamd. This prevents your log file from filling up with rspamd_monitored_dns_mon entries.


- type: ```boolean```
- default: ```True```

`````


`````{option} mailserver.mailDirectory
Where to store the mail.


- type: ```path```
- default: ```/var/vmail```

`````


`````{option} mailserver.mailboxes
The mailboxes for dovecot.
Depending on the mail client used it might be necessary to change some mailbox's name.


- type: ```unspecified value```
- default: ```{'Drafts': {'auto': 'subscribe', 'specialUse': 'Drafts'}, 'Junk': {'auto': 'subscribe', 'specialUse': 'Junk'}, 'Sent': {'auto': 'subscribe', 'specialUse': 'Sent'}, 'Trash': {'auto': 'no', 'specialUse': 'Trash'}}```

`````


`````{option} mailserver.maxConnectionsPerUser
Maximum number of IMAP/POP3 connections allowed for a user from each IP address.
E.g. a value of 50 allows for 50 IMAP and 50 POP3 connections at the same
time for a single user.


- type: ```signed integer```
- default: ```100```

`````


`````{option} mailserver.messageSizeLimit
Message size limit enforced by Postfix.

- type: ```signed integer```
- default: ```20971520```
- example: ```52428800```
`````


`````{option} mailserver.openFirewall
Automatically open ports in the firewall.

- type: ```boolean```
- default: ```True```

`````


`````{option} mailserver.policydSPFExtraConfig
Extra configuration options for policyd-spf. This can be use to among
other things skip spf checking for some IP addresses.


- type: ```strings concatenated with "\n"```
- default: `""`
- example: 
```
skip_addresses = 127.0.0.0/8,::ffff:127.0.0.0/104,::1
```
`````


`````{option} mailserver.rebootAfterKernelUpgrade.enable
Whether to enable automatic reboot after kernel upgrades.
This is to be used in conjunction with `system.autoUpgrade.enable = true;`


- type: ```boolean```
- default: ```False```
- example: ```True```
`````


`````{option} mailserver.rebootAfterKernelUpgrade.method
Whether to issue a full "reboot" or just a "systemctl kexec"-only reboot.
It is recommended to use the default value because the quicker kexec reboot has a number of problems.
Also if your server is running in a virtual machine the regular reboot will already be very quick.


- type: ```one of "reboot", "systemctl kexec"```
- default: ```reboot```

`````


`````{option} mailserver.recipientDelimiter
Configure the recipient delimiter.


- type: ```string```
- default: ```+```

`````


`````{option} mailserver.rejectRecipients
Reject emails addressed to these local addresses from unauthorized senders.
Use if a spammer has found email addresses in a catchall domain but you do
not want to disable the catchall.


- type: ```list of string```
- default: ```[]```
- example: ```['sales@example.com', 'info@example.com']```
`````


`````{option} mailserver.rejectSender
Reject emails from these addresses from unauthorized senders.
Use if a spammer is using the same domain or the same sender over and over.


- type: ```list of string```
- default: ```[]```
- example: ```['@example.com', 'spammer@example.net']```
`````


`````{option} mailserver.rewriteMessageId
Rewrites the Message-ID's hostname-part of outgoing emails to the FQDN.
Please be aware that this may cause problems with some mail clients
relying on the original Message-ID.


- type: ```boolean```
- default: ```False```

`````


`````{option} mailserver.sendingFqdn
The fully qualified domain name of the mail server used to
identify with remote servers.

If this server's IP serves purposes other than a mail server,
it may be desirable for the server to have a name other than
that to which the user will connect.  For example, the user
might connect to mx.example.com, but the server's IP has
reverse DNS that resolves to myserver.example.com; in this
scenario, some mail servers may reject or penalize the
message.

This setting allows the server to identify as
myserver.example.com when forwarding mail, independently of
{option}`mailserver.fqdn` (which, for SSL reasons, should generally be the name
to which the user connects).

Set this to the name to which the sending IP's reverse DNS
resolves.


- type: ```string```
- default: {option}`mailserver.fqdn`
- example: ```myserver.example.com```
`````


`````{option} mailserver.sieveDirectory
Where to store the sieve scripts.


- type: ```path```
- default: ```/var/sieve```

`````


`````{option} mailserver.useFsLayout
Sets whether dovecot should organize mail in subdirectories:

- /var/vmail/example.com/user/.folder.subfolder/ (default layout)
- /var/vmail/example.com/user/folder/subfolder/  (FS layout)

See https://wiki2.dovecot.org/MailboxFormat/Maildir for details.


- type: ```boolean```
- default: ```False```

`````


`````{option} mailserver.virusScanning
Whether to activate virus scanning. Note that virus scanning is _very_
expensive memory wise.


- type: ```boolean```
- default: ```False```

`````


`````{option} mailserver.vmailGroupName
The user name and group name of the user that owns the directory where all
the mail is stored.


- type: ```string```
- default: ```virtualMail```

`````


`````{option} mailserver.vmailUID
The unix UID of the virtual mail user.  Be mindful that if this is
changed, you will need to manually adjust the permissions of
`mailDirectory`.


- type: ```signed integer```
- default: ```5000```

`````


`````{option} mailserver.vmailUserName
The user name and group name of the user that owns the directory where all
the mail is stored.


- type: ```string```
- default: ```virtualMail```

`````

## `mailserver.loginAccounts`


`````{option} mailserver.loginAccounts
The login account of the domain. Every account is mapped to a unix user,
e.g. `user1@example.com`. To generate the passwords use `mkpasswd` as
follows

```
nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
```


- type: ```attribute set of (submodule)```
- default: ```{}```
- example: ```{'user1': {'hashedPassword': '$6$evQJs5CFQyPAW09S$Cn99Y8.QjZ2IBnSu4qf1vBxDRWkaIZWOtmu1Ddsm3.H3CFpeVc0JU4llIq8HQXgeatvYhh5O33eWG3TSpjzu6/'}, 'user2': {'hashedPassword': '$6$oE0ZNv2n7Vk9gOf$9xcZWCCLGdMflIfuA0vR1Q1Xblw6RZqPrP94mEit2/81/7AKj2bqUai5yPyWE.QYPyv6wLMHZvjw3Rlg7yTCD/'}}```
`````


`````{option} mailserver.loginAccounts.<name>.aliases
A list of aliases of this login account.
Note: Use list entries like "@example.com" to create a catchAll
that allows sending from all email addresses in these domain.


- type: ```list of string```
- default: ```[]```
- example: ```['abuse@example.com', 'postmaster@example.com']```
`````


`````{option} mailserver.loginAccounts.<name>.catchAll
For which domains should this account act as a catch all?
Note: Does not allow sending from all addresses of these domains.


- type: ```list of value "example.com" (singular enum)```
- default: ```[]```
- example: ```['example.com', 'example2.com']```
`````


`````{option} mailserver.loginAccounts.<name>.hashedPassword
The user's hashed password. Use `mkpasswd` as follows

```
nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
```

Warning: this is stored in plaintext in the Nix store!
Use {option}`mailserver.loginAccounts.<name>.hashedPasswordFile` instead.


- type: ```null or string```
- default: ```None```
- example: ```$6$evQJs5CFQyPAW09S$Cn99Y8.QjZ2IBnSu4qf1vBxDRWkaIZWOtmu1Ddsm3.H3CFpeVc0JU4llIq8HQXgeatvYhh5O33eWG3TSpjzu6/```
`````


`````{option} mailserver.loginAccounts.<name>.hashedPasswordFile
A file containing the user's hashed password. Use `mkpasswd` as follows

```
nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
```


- type: ```null or path```
- default: ```None```
- example: ```/run/keys/user1-passwordhash```
`````


`````{option} mailserver.loginAccounts.<name>.name
Username

- type: ```string```

- example: ```user1@example.com```
`````


`````{option} mailserver.loginAccounts.<name>.quota
Per user quota rules. Accepted sizes are `xx k/M/G/T` with the
obvious meaning. Leave blank for the standard quota `100G`.


- type: ```null or string```
- default: ```None```
- example: ```2G```
`````


`````{option} mailserver.loginAccounts.<name>.sendOnly
Specifies if the account should be a send-only account.
Emails sent to send-only accounts will be rejected from
unauthorized senders with the `sendOnlyRejectMessage`
stating the reason.


- type: ```boolean```
- default: ```False```

`````


`````{option} mailserver.loginAccounts.<name>.sendOnlyRejectMessage
The message that will be returned to the sender when an email is
sent to a send-only account. Only used if the account is marked
as send-only.


- type: ```string```
- default: ```This account cannot receive emails.```

`````


`````{option} mailserver.loginAccounts.<name>.sieveScript
Per-user sieve script.


- type: ```null or strings concatenated with "\n"```
- default: ```None```
- example: 
```
require ["fileinto", "mailbox"];

if address :is "from" "gitlab@mg.gitlab.com" {
  fileinto :create "GitLab";
  stop;
}

# This must be the last rule, it will check if list-id is set, and
# file the message into the Lists folder for further investigation
elsif header :matches "list-id" "<?*>" {
  fileinto :create "Lists";
  stop;
}
```
`````

## `mailserver.certificate`


`````{option} mailserver.certificateDirectory
Scheme 2)
This is the folder where the certificate will be created. The name is
hardcoded to "cert-DOMAIN.pem" and "key-DOMAIN.pem" and the
certificate is valid for 10 years.


- type: ```path```
- default: ```/var/certs```

`````


`````{option} mailserver.certificateDomains
Secondary domains and subdomains for which it is necessary to generate a certificate.

- type: ```list of string```
- default: ```[]```
- example: ```['imap.example.com', 'pop3.example.com']```
`````


`````{option} mailserver.certificateFile
Scheme 1)
Location of the certificate


- type: ```path```

- example: ```/root/mail-server.crt```
`````


`````{option} mailserver.certificateScheme
Certificate Files. There are three options for these.

1) You specify locations and manually copy certificates there.
2) You let the server create new (self signed) certificates on the fly.
3) You let the server create a certificate via `Let's Encrypt`. Note that
   this implies that a stripped down webserver has to be started. This also
   implies that the FQDN must be set as an `A` record to point to the IP of
   the server. In particular port 80 on the server will be opened. For details
   on how to set up the domain records, see the guide in the readme.


- type: ```one of 1, 2, 3```
- default: ```2```

`````

## `mailserver.dkim`


`````{option} mailserver.dkimBodyCanonicalization
DKIM canonicalization algorithm for message bodies.

See https://datatracker.ietf.org/doc/html/rfc6376/#section-3.4 for details.


- type: ```one of "relaxed", "simple"```
- default: ```relaxed```

`````


`````{option} mailserver.dkimHeaderCanonicalization
DKIM canonicalization algorithm for message headers.

See https://datatracker.ietf.org/doc/html/rfc6376/#section-3.4 for details.


- type: ```one of "relaxed", "simple"```
- default: ```relaxed```

`````


`````{option} mailserver.dkimKeyBits
How many bits in generated DKIM keys. RFC6376 advises minimum 1024-bit keys.

If you have already deployed a key with a different number of bits than specified
here, then you should use a different selector ({option}`mailserver.dkimSelector`). In order to get
this package to generate a key with the new number of bits, you will either have to
change the selector or delete the old key file.


- type: ```signed integer```
- default: ```1024```

`````


`````{option} mailserver.dkimKeyDirectory
The DKIM directory.


- type: ```path```
- default: ```/var/dkim```

`````


`````{option} mailserver.dkimSelector
The DKIM selector.


- type: ```string```
- default: ```mail```

`````


`````{option} mailserver.dkimSigning
Whether to activate dkim signing.


- type: ```boolean```
- default: ```True```

`````

## `mailserver.dmarcReporting`


`````{option} mailserver.dmarcReporting.domain
The domain from which outgoing DMARC reports are served.


- type: ```value "example.com" (singular enum)```

- example: ```example.com```
`````


`````{option} mailserver.dmarcReporting.email
The email address used for outgoing DMARC reports. Read-only.


- type: ```string```
- default: ```"${localpart}@${domain}"```

`````


`````{option} mailserver.dmarcReporting.enable
Whether to send out aggregated, daily DMARC reports in response to incoming
mail, when the sender domain defines a DMARC policy including the RUA tag.

This is helpful for the mail ecosystem, because it allows third parties to
get notified about SPF/DKIM violations originating from their sender domains.

See https://rspamd.com/doc/modules/dmarc.html#reporting


- type: ```boolean```
- default: ```False```

`````


`````{option} mailserver.dmarcReporting.fromName
The sender name for DMARC reports. Defaults to the organization name.


- type: ```string```
- default: {option}`mailserver.dmarcReporting.organizationName`

`````


`````{option} mailserver.dmarcReporting.localpart
The local part of the email address used for outgoing DMARC reports.


- type: ```string```
- default: ```dmarc-noreply```
- example: ```dmarc-report```
`````


`````{option} mailserver.dmarcReporting.organizationName
The name of your organization used in the `org_name` attribute in
DMARC reports.


- type: ```string```

- example: ```ACME Corp.```
`````

## `mailserver.fullTextSearch`


`````{option} mailserver.fullTextSearch.autoIndex
Enable automatic indexing of messages as they are received or modified.

- type: ```boolean```
- default: ```True```

`````


`````{option} mailserver.fullTextSearch.autoIndexExclude
Mailboxes to exclude from automatic indexing.


- type: ```list of string```
- default: ```[]```
- example: ```['\\Trash', 'SomeFolder', 'Other/*']```
`````


`````{option} mailserver.fullTextSearch.enable
Whether to enable Full text search indexing with xapian. This has significant performance and disk space cost..

- type: ```boolean```
- default: ```False```
- example: ```True```
`````


`````{option} mailserver.fullTextSearch.enforced
Fail searches when no index is available. If set to
`body`, then only body searches (as opposed to
header) are affected. If set to `no`, searches may
fall back to a very slow brute force search.


- type: ```one of "yes", "no", "body"```
- default: ```no```

`````


`````{option} mailserver.fullTextSearch.indexAttachments
Also index text-only attachements. Binary attachements are never indexed.

- type: ```boolean```
- default: ```False```

`````


`````{option} mailserver.fullTextSearch.maintenance.enable
Regularly optmize indices, as recommended by upstream.

- type: ```boolean```
- default: ```True```

`````


`````{option} mailserver.fullTextSearch.maintenance.onCalendar
When to run the maintenance job. See systemd.time(7) for more information about the format.

- type: ```string```
- default: ```daily```

`````


`````{option} mailserver.fullTextSearch.maintenance.randomizedDelaySec
Run the maintenance job not exactly at the time specified with `onCalendar`, but plus or minus this many seconds.

- type: ```signed integer```
- default: ```1000```

`````


`````{option} mailserver.fullTextSearch.maxSize
Size of the largest n-gram to index.

- type: ```signed integer```
- default: ```20```

`````


`````{option} mailserver.fullTextSearch.memoryLimit
Memory limit for the indexer process, in MiB. If null, leaves the default (which is rather low), and if 0, no limit.

- type: ```null or signed integer```
- default: ```None```
- example: ```2000```
`````


`````{option} mailserver.fullTextSearch.minSize
Size of the smallest n-gram to index.

- type: ```signed integer```
- default: ```2```

`````

## `mailserver.redis`


`````{option} mailserver.redis.address
Address that rspamd should use to contact redis.


- type: ```string```
- default: computed from `config.services.redis.servers.rspamd.bind`

`````


`````{option} mailserver.redis.password
Password that rspamd should use to contact redis, or null if not required.


- type: ```null or string```
- default: ```config.services.redis.servers.rspamd.requirePass```

`````


`````{option} mailserver.redis.port
Port that rspamd should use to contact redis.


- type: ```16 bit unsigned integer; between 0 and 65535 (both inclusive)```
- default: ```config.services.redis.servers.rspamd.port```

`````

## `mailserver.monitoring`


`````{option} mailserver.monitoring.alertAddress
The email address to send alerts to.


- type: ```string```


`````


`````{option} mailserver.monitoring.config
The configuration used for monitoring via monit.
Use a mail address that you actively check and set it via 'set alert ...'.


- type: ```string```
- default: see [source](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/blob/master/default.nix)

`````


`````{option} mailserver.monitoring.enable
Whether to enable monitoring via monit.

- type: ```boolean```
- default: ```False```
- example: ```True```
`````

## `mailserver.backup`


`````{option} mailserver.backup.cmdPostexec
The command to be executed after each backup operation. This is wrapped in a shell script to be called by rsnapshot.

- type: ```null or string```
- default: ```None```

`````


`````{option} mailserver.backup.cmdPreexec
The command to be executed before each backup operation. This is wrapped in a shell script to be called by rsnapshot.


- type: ```null or string```
- default: ```None```

`````


`````{option} mailserver.backup.cronIntervals
Periodicity at which intervals should be run by cron.
Note that the intervals also have to exist in configuration
as retain options.


- type: ```attribute set of string```
- default: ```{'daily': '30  3  *  *  *', 'hourly': ' 0  *  *  *  *', 'weekly': ' 0  5  *  *  0'}```

`````


`````{option} mailserver.backup.enable
Whether to enable backup via rsnapshot.

- type: ```boolean```
- default: ```False```
- example: ```True```
`````


`````{option} mailserver.backup.retain.daily
How many daily snapshots are retained.

- type: ```signed integer```
- default: ```7```

`````


`````{option} mailserver.backup.retain.hourly
How many hourly snapshots are retained.

- type: ```signed integer```
- default: ```24```

`````


`````{option} mailserver.backup.retain.weekly
How many weekly snapshots are retained.

- type: ```signed integer```
- default: ```54```

`````


`````{option} mailserver.backup.snapshotRoot
The directory where rsnapshot stores the backup.


- type: ```path```
- default: ```/var/rsnapshot```

`````

## `mailserver.borgbackup`


`````{option} mailserver.borgbackup.cmdPostexec
The command to be executed after each backup operation.
This is called after borg create completed successfully and in the same script that runs
`cmdPreexec`, borg init and create.


- type: ```null or string```
- default: ```None```

`````


`````{option} mailserver.borgbackup.cmdPreexec
The command to be executed before each backup operation.
This is called prior to borg init in the same script that runs borg init and create and `cmdPostexec`.


- type: ```null or string```
- default: ```None```
- example: 
```
export BORG_RSH="ssh -i /path/to/private/key"
```
`````


`````{option} mailserver.borgbackup.compression.auto
Leaves it to borg to determine whether an individual file should be compressed.

- type: ```boolean```
- default: ```False```

`````


`````{option} mailserver.borgbackup.compression.level
Denotes the level of compression used by borg.
Most methods accept levels from 0 to 9 but zstd which accepts values from 1 to 22.
If null the decision is left up to borg.


- type: ```null or signed integer```
- default: ```None```

`````


`````{option} mailserver.borgbackup.compression.method
Leaving this unset allows borg to choose. The default for borg 1.1.4 is lz4.

- type: ```null or one of "none", "lz4", "zstd", "zlib", "lzma"```
- default: ```None```

`````


`````{option} mailserver.borgbackup.enable
Whether to enable backup via borgbackup.

- type: ```boolean```
- default: ```False```
- example: ```True```
`````


`````{option} mailserver.borgbackup.encryption.method
The backup can be encrypted by choosing any other value than 'none'.
When using encryption the password/passphrase must be provided in `passphraseFile`.


- type: ```one of "none", "authenticated", "authenticated-blake2", "repokey", "keyfile", "repokey-blake2", "keyfile-blake2"```
- default: ```none```

`````


`````{option} mailserver.borgbackup.encryption.passphraseFile
Path to a file containing the encryption password or passphrase.

- type: ```null or path```
- default: ```None```

`````


`````{option} mailserver.borgbackup.extraArgumentsForCreate
Additional arguments to add to the borg create command line e.g. '--stats'.

- type: ```list of string```
- default: ```[]```

`````


`````{option} mailserver.borgbackup.extraArgumentsForInit
Additional arguments to add to the borg init command line.

- type: ```list of string```
- default: ```['--critical']```

`````


`````{option} mailserver.borgbackup.group
The group borg and its launch script is run as.

- type: ```string```
- default: ```virtualMail```

`````


`````{option} mailserver.borgbackup.locations
The locations that are to be backed up by borg.

- type: ```list of path```
- default: ```[ config.mailserver.mailDirectory ]```

`````


`````{option} mailserver.borgbackup.name
The name of the individual backups as used by borg.
Certain placeholders will be replaced by borg.


- type: ```string```
- default: ```{hostname}-{user}-{now}```

`````


`````{option} mailserver.borgbackup.repoLocation
The location where borg saves the backups.
This can be a local path or a remote location such as user@host:/path/to/repo.
It is exported and thus available as an environment variable to
{option}`mailserver.borgbackup.cmdPreexec` and {option}`mailserver.borgbackup.cmdPostexec`.


- type: ```string```
- default: ```/var/borgbackup```

`````


`````{option} mailserver.borgbackup.startAt
When or how often the backup should run. Must be in the format described in systemd.time 7.

- type: ```string```
- default: ```hourly```

`````


`````{option} mailserver.borgbackup.user
The user borg and its launch script is run as.

- type: ```string```
- default: ```virtualMail```

`````

