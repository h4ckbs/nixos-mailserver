import json
import sys
import re
import textwrap

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
{example}
"""

f = open(sys.argv[1])
options = json.load(f)

options = {k: v for k, v in options.items()
           if k.startswith("mailserver.")}

groups = ["mailserver.loginAccount",
          "mailserver.certificate",
          "mailserver.dkim",
          "mailserver.dmarcReporting",
          "mailserver.fullTextSearch",
          "mailserver.redis",
          "mailserver.monitoring",
          "mailserver.backup",
          "mailserver.borg"]

def render_option_value(opt, attr):
  if attr in opt:
      if isinstance(opt[attr], dict) and '_type' in opt[attr]:
          if opt[attr]['_type'] == 'literalExpression':
              if '\n' in opt[attr]['text']:
                  res = '\n.. code:: nix\n\n' + textwrap.indent(opt[attr]['text'], '  ') + '\n'
              else:
                  res = '``{}``'.format(opt[attr]['text'])
          elif opt[attr]['_type'] == 'literalDocBook':
              res = opt[attr]['text']
      else:
          s = str(opt[attr])
          if s == "":
              res = '``""``'
          elif '\n' in s:
              res = '\n.. code::\n\n' + textwrap.indent(s, '  ') + '\n'
          else:
              res = '``{}``'.format(s)
      res = '- ' + attr + ': ' + res
  else:
      res = ""
  return res

def print_option(name, value):
    print(template.format(
        key=name,
        line="-"*len(name),
        description=value['description'] or "",
        type="- type: ``{}``".format(value['type']),
        default=render_option_value(value, 'default'),
        example=render_option_value(value, 'example')))


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
