#!/bin/bash

if [ -n "$1" ]; then
    SNAP_DIR="/backup/snapshots/$1"
else
    SNAP_DIR="/backup/snapshots/$(date +%Y%m%d-%H%M)"
fi

EXCLUDE="/backup/exclude.list"


mkdir -p "$SNAP_DIR"

echo "[\e[36m INFO \e[0m] Snapshot '${SNAP_DIR}' saveing..."
rsync -aAXH --info=progress2 --delete --exclude-from="$EXCLUDE" / "$SNAP_DIR/"
echo "[\e[32m OK \e[0m] Snapshot save as '$SNAP_DIR'"
