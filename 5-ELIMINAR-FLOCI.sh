#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 1
bash _interno/eliminar-floci.sh "$@"
