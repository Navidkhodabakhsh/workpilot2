#!/usr/bin/env bash
# One-command "sync from the VMware shared folder, then (re)build & start"
# for this specific dev workflow: project files land in a folder named
# exactly "workpilot2" inside the VMware shared folder (mounted under
# /mnt/hgfs on the Ubuntu guest); this script copies them into a native
# path in the VM (avoids building Docker images directly off the hgfs
# network filesystem, and avoids hgfs sometimes losing the executable bit
# on install.sh) and then runs install.sh.
#
# One-time setup:  sudo cp run.sh /usr/local/bin/run && sudo chmod +x /usr/local/bin/run
# From then on, from any terminal:  run
set -euo pipefail

DEST="$HOME/workpilot2"

SRC=$(find /mnt/hgfs -mindepth 1 -maxdepth 2 -type d -name workpilot2 2>/dev/null | head -1 || true)
if [ -z "$SRC" ]; then
  echo "Couldn't find a 'workpilot2' folder under /mnt/hgfs." >&2
  echo "Make sure the project files are inside a folder named exactly" >&2
  echo "'workpilot2' in your VMware shared folder." >&2
  exit 1
fi

command -v rsync &>/dev/null || { sudo apt-get update -qq && sudo apt-get install -y rsync; }

mkdir -p "$DEST"
rsync -a --delete --exclude ".venv" --exclude "node_modules" "$SRC"/ "$DEST"/
cd "$DEST"
chmod +x install.sh
exec ./install.sh
