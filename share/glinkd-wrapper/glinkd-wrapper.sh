#!/bin/bash
set -e
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REAL="$SCRIPT_DIR/glinkd.real"
if [ ! -x "$REAL" ]; then
    echo "ERROR: $REAL not found" >&2
    exit 1
fi
LD_PRELOAD="$SCRIPT_DIR/glinkd_init_patch.so${LD_PRELOAD:+:$LD_PRELOAD}" exec "$REAL" "$@"
