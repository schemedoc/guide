#!/bin/sh
set -eu
cd "$(dirname "$0")"
rsync -crv www/ alpha.servers.scheme.org:/production/doc/www/guide/
