#!/bin/sh

set -e

cd "$(dirname "${0}")"

rm ./*.cvd hashes.json || :

freshclam --datadir=. --config-file=freshclam.conf
(for i in ./*.cvd;
 do echo '{}' |
     jq --arg path "$(basename "${i}")" \
        --arg sha256sum "$(sha256sum "${i}" | awk '{ print $1; }')" \
        '.[$path] = $sha256sum'; done) |
  jq -s add > hashes.json
