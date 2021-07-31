#!/bin/bash
set -eu -o pipefail
cd "$(dirname "$0")"
mkdir -p www
find www/ -mindepth 1 -delete
for adoc in $(git ls-files | grep -F .adoc); do
    stem="$(echo "$adoc" | sed 's@\.adoc$@@')"
    hdir="www/$stem"
    html="$hdir/index.html"
    echo "$html"
    asciidoctor -b html5 -o "$html" "$adoc"
done
