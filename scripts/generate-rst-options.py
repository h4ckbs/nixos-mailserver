import json
import sys

header = """
Mailserver Options
==================

mailserver
~~~~~~~~~~

"""

template = """
{key}
{line}

{description}

{type}
{default}
"""

f = open(sys.argv[1])
options = json.load(f)

options = { k: v for k, v in options.items() if k.startswith("mailserver.") }

groups = [ "mailserver.loginAccount",
           "mailserver.certificate",
           "mailserver.dkim",
           "mailserver.fullTextSearch",
           "mailserver.redis",
           "mailserver.monitoring",
           "mailserver.backup",
           "mailserver.borg" ]

def print_option(name, value):
    if 'default' in v:
        if v['default'] == "":
            default = '- Default: ``""``'
        else:
            default = '- Default: ``{}``'.format(v['default'])
    else:
        default = ""
    print(template.format(
        key=k,
        line="-"*len(k),
        description=v['description'],
        type="- Type: ``{}``".format(v['type']),
        default=default))

print(header)
for k, v in options.items():
    if any([k.startswith(c) for c in groups]):
        continue
    print_option(k, v)

for c in groups:
    print(c)
    print("~"*len(c))
    print()
    for k, v in options.items():
        if k.startswith(c):
            print_option(k, v)
