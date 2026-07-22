#!/usr/bin/env bash
# Permanent launcher for the `run` command -- install this ONE time:
#   sudo cp run-bootstrap.sh /usr/local/bin/run && sudo chmod +x /usr/local/bin/run
#
# Unlike the old setup (installing run.sh itself as /usr/local/bin/run,
# a static snapshot that silently went stale every time run.sh changed
# in a newer zip), this file's only job is to find and hand off to
# run.sh wherever it currently lives, then get out of the way. Fixes or
# features added to run.sh in a future zip apply on your very next
# `run` -- this bootstrap itself should never need to be re-copied.
#
# Also handles a zip file dropped directly into the shared folder: no
# need to manually extract it first.
set -euo pipefail

SHARE="/mnt/hgfs"

# Most-recently-modified *.zip anywhere up to one subfolder deep in the
# share (so it doesn't matter whether it's dropped at the top level or
# inside e.g. a Downloads folder). If none is found, fall back to
# treating the share itself as an already-extracted project.
ZIP_FILE=$(find "$SHARE" -maxdepth 2 -type f -iname "*.zip" -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2- || true)

if [ -n "${ZIP_FILE:-}" ]; then
  command -v unzip &>/dev/null || { sudo apt-get update -qq && sudo apt-get install -y unzip; }
  EXTRACT_DIR="/tmp/workpilot2-source"
  rm -rf "$EXTRACT_DIR"
  mkdir -p "$EXTRACT_DIR"
  unzip -q "$ZIP_FILE" -d "$EXTRACT_DIR"
  SEARCH_ROOT="$EXTRACT_DIR"
else
  SEARCH_ROOT="$SHARE"
fi

RUN_SCRIPT=$(find "$SEARCH_ROOT" -mindepth 1 -maxdepth 3 -type f -name run.sh 2>/dev/null | head -1 || true)
if [ -z "$RUN_SCRIPT" ]; then
  echo "Couldn't find run.sh anywhere under $SEARCH_ROOT." >&2
  echo "Make sure the project zip (or extracted folder) is inside your" >&2
  echo "VMware shared folder." >&2
  exit 1
fi

chmod +x "$RUN_SCRIPT"
exec "$RUN_SCRIPT"
