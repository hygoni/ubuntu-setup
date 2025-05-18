#!/bin/bash

set -euo pipefail

SUDOERS="/etc/sudoers"
BACKUP="/etc/sudoers.bak.$(date +%Y%m%d_%H%M%S)"
TMP=$(mktemp)

cp -p "$SUDOERS" "$BACKUP"

cp "$SUDOERS" "$TMP"

sed -E -i \
  -e '/^\s*%sudo\b/  s/ALL=\(ALL(:ALL)?\)\s+ALL/ALL=(ALL:ALL) NOPASSWD:ALL/' \
  -e '/^\s*%admin\b/ s/ALL=\(ALL(:ALL)?\)\s+ALL/ALL=(ALL)     NOPASSWD:ALL/' \
  "$TMP"

if ! visudo -c -f "$TMP" >/dev/null; then
    echo "Validation failed. sudoers change not applied." >&2
    echo "Backup: $BACKUP" >&2
    exit 1
fi

# Atomic Update
install -m 0440 "$TMP" "$SUDOERS"
rm -f "$TMP"

echo "Sudoers update finished. Now you don't need password for sudo."
