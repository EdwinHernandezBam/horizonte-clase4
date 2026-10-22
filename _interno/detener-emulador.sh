#!/usr/bin/env bash
HERR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREP="$(cd "$HERR/.." && pwd)"
docker rm -f floci-clase4 >/dev/null 2>&1 && echo "Floci detenido."
exit 0
