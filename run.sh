#!/usr/bin/env bash
# One-command "sync from the VMware shared folder, then (re)build & start"
# for this specific dev workflow: project files land somewhere under the
# VMware shared folder (mounted under /mnt/hgfs on the Ubuntu guest), at
# any nesting depth up to 2 (found by locating docker-compose.yml, so it
# doesn't matter whether it's directly in the share or in a subfolder).
# This script copies them into a native path in the VM (avoids building
# Docker images directly off the hgfs network filesystem, and avoids hgfs
# sometimes losing the executable bit on install.sh) and then runs
# install.sh.
#
# One-time setup:  sudo cp run.sh /usr/local/bin/run && sudo chmod +x /usr/local/bin/run
# From then on, from any terminal:  run
set -euo pipefail

DEST="$HOME/workpilot2"

COMPOSE_FILE=$(find /mnt/hgfs -mindepth 1 -maxdepth 3 -type f -name docker-compose.yml 2>/dev/null | head -1 || true)
if [ -z "$COMPOSE_FILE" ]; then
  echo "Couldn't find docker-compose.yml anywhere under /mnt/hgfs." >&2
  echo "Make sure the extracted project files are somewhere inside your" >&2
  echo "VMware shared folder." >&2
  exit 1
fi
SRC=$(dirname "$COMPOSE_FILE")

command -v rsync &>/dev/null || { sudo apt-get update -qq && sudo apt-get install -y rsync; }

mkdir -p "$DEST"
rsync -a --delete --exclude ".venv" --exclude "node_modules" "$SRC"/ "$DEST"/
cd "$DEST"
chmod +x install.sh
exec ./install.sh
